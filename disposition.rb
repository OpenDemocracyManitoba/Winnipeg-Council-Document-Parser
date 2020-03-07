# frozen_string_literal: true

require 'docx'
require 'date'

# Problem:
#
# Scrape City of Winnipeg Council meeting dispositions from a Word document.
#
# Knows:
#
# - The Winnipeg Clerks Dept records council dispositions in Word documents.
# - The Clerks Dept structures disposition documents using tables.
# - Word documents (*.docx) are actually compressed zip files full of XML.
# - The docx Rubygem has a simple API for interacting with Word documents.
# - The docx gem can extract disposition data by searching for table headers.
# - Tables found in the disposition document:
#   + Attendance (Council and Public Servants)
#   + Bylaws Passed on Third Reading
#   + Bylaws Receiving First Reading
#   + Notice of Motions
#   + Motions
#   + Reports
#   + Recorded Votes
#   + Conflict of Interest Declarations

class Disposition
  # Table Headers Used for Dispositoin Extraction
  ATTENDANCE_TITLE       = /MEMBERS PRESENT/.freeze
  BYLAWS_PASSED_TITLE    = /BY-LAWS PASSED \(RECEIVED THIRD READING\)/.freeze
  BYLAWS_FIRST_TITLE     = /BY-LAWS RECEIVING FIRST READING ONLY/.freeze
  COUNCIL_MOTIONS_TITLE  = /COUNCIL MOTIONS/.freeze
  NOTICE_OF_MOTION_TITLE = /NOTICE OF MOTION/.freeze
  REPORT_TITLE           = /^REPORT/.freeze

  # Dispositions are built from a path to a docx disposition document.
  def initialize(docx_file_path)
    # Use the private getter to access @doc within this class.
    @doc = Docx::Document.open(docx_file_path)
  end

  # Public API
  #
  # Written as one-liners to read like a table of contents.
  #
  # API Behaviour Specification: spec/disposition_spec.rb

  def meeting_date
    scan_for_meeting_date
  end

  def bylaws_passed
    bylaws_passed_collection
  end

  def bylaws_first_reading
    bylaws_first_reading_collection
  end

  def notice_of_motions
    notice_of_motions_collection
  end

  def motions
    motions_collection
  end

  def reports
    reports_collection
  end

  def attendance_council
    attendance_collection[:council]
  end

  def attendance_public_service
    attendance_collection[:public_service]
  end

  def recorded_votes
    recorded_votes_collection
  end

  def conflict_of_interest_declarations
    conflict_of_interest_declarations_collection
  end

  # Extracted disposition as hash.
  # This hash can be easily converted to JSON for file export.
  def to_h
    {
      meeting_date:                      scan_for_meeting_date,
      attendance:                        attendance_collection,
      reports:                           reports_collection,
      notice_of_motions:                 notice_of_motions_collection,
      motions:                           motions_collection,
      bylaws_first_reading:              bylaws_first_reading_collection,
      bylaws_passed:                     bylaws_passed_collection,
      recorded_votes:                    recorded_votes_collection,
      conflict_of_interest_declarations: conflict_of_interest_declarations_collection
    }
  end

  private

  # MEETING DATE
  # Builds an array of parsed dates for the first 20 document paragraphs. If
  # parsing fails nil, is added to the array. Parsed date collection is then
  # compacted to remove nils. The first, and likely only, parsed date in the
  # collection is the meeting date.
  #
  # Date::parse docs warn against using it as a date validator --I imagine
  # it's very permissive-- but that's what I'm doing here.

  def scan_for_meeting_date
    doc.paragraphs[0..20].map do |paragraph|
      # Exceptional handling as validator. :S

      Date.parse(paragraph.text)
    rescue ArgumentError
      nil
    end.compact.first
  end

  # ATTENDANCE
  # Single table with header row, but no title row.
  # First column is council attendance.
  # Second column is public service attendance.

  def attendance_collection
    attendance_table_rows = select_table(ATTENDANCE_TITLE, 1)

    attendance = attendance_table_rows.map do |attendee_row|
      attendance_builder(attendee_row)
    end

    {
      council:        attendance.map(&:first),
      public_service: attendance.map(&:last).reject(&:empty?)
    }
  end

  def attendance_builder(attendee_row)
    row_cells_to_text_columns(attendee_row)
  end

  # REPORTS
  # Unlike motions or bylaws, reports are stored in multiple tables.
  # The reports collection will be an array of hashes.
  # Each hash has a report title and an array of report items.

  def reports_collection
    report_tables = select_tables(REPORT_TITLE)

    report_tables.map do |report_table|
      report_builder(report_table)
    end
  end

  def report_builder(report_table)
    title     = report_table.rows[0].cells[0].text
    date      = Date.parse(title.split('dated').last.strip)
    committee = title.match(/REPORT.+OF THE (.+) dated (.+)/i)[1]
    committee = committee.split(' ').map(&:capitalize).join(' ')

    { title:     title,
      date:      date,
      committee: committee,
      items:     report_items(report_table) }
  end

  def report_items(report_table)
    item_rows = report_table.rows[1..-1] # Skip the first title row.

    item_rows.map do |item_row|
      report_item_builder(item_row)
    end
  end

  def report_item_builder(item_row)
    item_columns = row_cells_to_text_columns(item_row)

    { number:      item_columns[0],
      title:       item_columns[1],
      disposition: item_columns[2] }
  end

  # NOTICE OF MOTIONS
  # All motions are assumed to be in a single table.
  # Motion subject may contain lists and other formatting, currently
  # this markup is ignore and converted to text only.

  def notice_of_motions_collection
    motion_table_rows = select_table(NOTICE_OF_MOTION_TITLE, 2)

    motion_table_rows.map do |motion_row|
      notice_of_motion_builder(motion_row)
    end
  end

  def notice_of_motion_builder(motion_row)
    motion_columns = row_cells_to_text_columns(motion_row)

    { movers:      split_mover_names(motion_columns[0]),
      subject:     motion_columns[1],
      disposition: motion_columns[2] }
  end

  # MOTIONS
  # All motions are assumed to be in a single table.
  # Motion subject may contain lists and other formatting, currently
  # this markup is ignore and converted to text only.

  def motions_collection
    motion_table_rows = select_table(COUNCIL_MOTIONS_TITLE, 2)

    motion_table_rows.map do |motion_row|
      motion_builder(motion_row)
    end
  end

  def split_mover_names(movers_text)
    movers_text.split('/').map(&:strip)
  end

  def motion_builder(motion_row)
    motion_columns = row_cells_to_text_columns(motion_row)

    { number:      motion_columns[0],
      movers:      split_mover_names(motion_columns[1]),
      subject:     motion_columns[2],
      disposition: motion_columns[3] }
  end

  # BYLAWS - FIRST READING
  # Bylaws are assumed to be stored in a single table.

  def bylaws_first_reading_collection
    bylaw_table_rows = select_table(BYLAWS_FIRST_TITLE, 2)

    bylaw_table_rows.map do |bylaw_row|
      bylaw_builder(bylaw_row)
    end
  end

  def bylaw_builder(bylaw_row)
    bylaw_columns = row_cells_to_text_columns(bylaw_row)

    { number:      bylaw_columns[0],
      subject:     bylaw_columns[1],
      disposition: bylaw_columns[2] }
  end

  # BYLAWS PASSED
  # Bylaws are assumed to be stored in a single table.

  def bylaws_passed_collection
    bylaw_table_rows = select_table(BYLAWS_PASSED_TITLE, 2)

    bylaw_table_rows.map do |bylaw_row|
      bylaw_builder(bylaw_row)
    end
  end

  # RECORDED VOTES
  # Includes a title row.

  # TODO: Does this title contain a typo? Should RECORDS be REPORTS?
  #       Forth word wildcarded 7 letters starting with R to support both.
  RECORDED_VOTES_TITLE = /RECORDED VOTES FOR R......, MOTIONS AND BY-LAWS/.freeze

  # Includes a header row with four column headers:
  # - Subject
  # - Yeas
  # - Nays
  # - Disposition
  #
  # NOTE: The Yeas and Nays are sometimes separated into multiple rows
  # within a table, and sometimes they are separated by newlines with a
  # single table cell! Code doesn't handle for this, so the affected
  # tables are manually fixed in Word.
  # NOTE 2: Sometimes an empty list of voters contains a single voter of "NIL".

  def recorded_votes_collection
    recorded_votes_table_rows = select_table(RECORDED_VOTES_TITLE, 2)

    recorded_votes_table_rows.map do |recorded_votes_row|
      recorded_votes_builder(recorded_votes_row)
    end
  end

  def recorded_votes_builder(votes_row)
    votes_columns = row_cells_to_text_columns(votes_row)

    {
      subject:     votes_columns[0],
      disposition: votes_columns[3],
      yeas:        cell_paragraphs(votes_row.cells[1]).reject { |voter| voter.strip == 'NIL' },
      nays:        cell_paragraphs(votes_row.cells[2]).reject { |voter| voter.strip == 'NIL' }
    }
  end

  # CONFLICT OF INTEREST DECLARATIONS

  DECLARATIONS_TITLE = /CONFLICT OF INTEREST DECLARATIONS/.freeze

  def conflict_of_interest_declarations_collection
    declaration_table_rows = select_table(DECLARATIONS_TITLE, 2)

    declaration_table_rows.map do |declaration_row|
      declaration_builder(declaration_row)
    end
  end

  def declaration_builder(declaration_row)
    declarations_columns = row_cells_to_text_columns(declaration_row)

    {
      subject: declarations_columns[0],
      members: cell_paragraphs(declaration_row.cells[1])
    }
  end

  # TABLE HELPERS
  # These table helpers feel like the start of a class.
  # I've tried to spike the class a few times, but it grew overly complex.

  attr_reader :doc

  def tables
    doc.tables
  end

  # Find all tables in the document where the top/left
  # cell text matches a given regexp.
  # Returns an array of tables.
  def select_tables(heading_regexp)
    tables.select do |t|
      heading_regexp.match(t.rows[0].cells[0].text)
    end
  end

  # Find the first table in the document where the top/left
  # cell text matches a given regexp.
  # Returns a single table.
  def select_table(heading_regexp, number_of_header_rows)
    table = tables.find do |t|
      heading_regexp.match(t.rows[0].cells[0].text)
    end
    # If not table was found, return an empty array instead of nil.
    table ? table.rows[number_of_header_rows..-1] : []
  end

  # Take a docx array of cells and convert into
  # an array of Strings built from the cell paragraph's text.
  def row_cells_to_text_columns(table_row)
    table_row.cells.map do |cell|
      # Join paragraphs into a String using a space delimiter.
      cell_paragraphs(cell).join(' ')
    end
  end

  # Takes a docx table cell as input.
  # Returns a collection of Strings, one per cell paragraph.
  # Blank or whitespace-only paragraphs are removed.
  def cell_paragraphs(cell)
    cell.paragraphs
        .map(&:text)       # Extract the text from each paragraph
        .map(&:strip)      # Remove leading/trailing spaces from text
        .reject(&:empty?)  # Throw away blank paragraphs
  end
end
