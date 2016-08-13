# frozen_string_literal: true
require 'docx'

# Problem:
# Scrape City of Winnipeg Council meeting dispositions from a Word document.
#
# Knows:
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
#
# TODO:
# - Conflict of interest declaration scraping. Often not present.
# - 2016-04-27 fixture: Fix table connection between motions and passed bylaws.
# - Null Objects or Empty Arrays needed for public API for optional sections?
# - Download all available Word Dispositions.
# - Update all recorded votes lists to text paragraphs.
# - Convert all dispositions to JSON.

class Disposition
  # Table Headers Used for Dispositoin Extraction
  ATTENDANCE_TITLE       = /MEMBERS PRESENT/
  BYLAWS_PASSED_TITLE    = /BY-LAWS PASSED \(RECEIVED THIRD READING\)/
  BYLAWS_FIRST_TITLE     = /BY-LAWS RECEIVING FIRST READING ONLY/
  COUNCIL_MOTIONS_TITLE  = /COUNCIL MOTIONS/
  NOTICE_OF_MOTION_TITLE = /NOTICE OF MOTION/
  REPORT_TITLE           = /^REPORT/

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
      bylaws_passed:        bylaws_passed_collection,
      bylaws_first_reading: bylaws_first_reading_collection,
      motions:              motions_collection,
      reports:              reports_collection,
      attendance:           attendance_collection,
      recorded_votes:       recorded_votes_collection
    }
  end

  private

  # ATTENDANCE
  # Single table with header row, but no title row.
  # First column is council attendance.
  # Second column is public service attendance.

  def attendance_collection
    attendance_table = select_table(ATTENDANCE_TITLE)
    attendance_table_rows = attendance_table.rows[1..-1] # Header row removed.

    attendance = attendance_table_rows.map do |attendee_row|
      attendance_builder(attendee_row)
    end

    {
      council: attendance.map(&:first),
      public_service: attendance.map(&:last).reject(&:empty?)
    }
  end

  def attendance_builder(attendee_row)
    row_cells_to_text_columns(attendee_row)
  end

  # BYLAWS - FIRST READING
  # Bylaws are assumed to be stored in a single table.

  def bylaws_first_reading_collection
    bylaw_table      = select_table(BYLAWS_FIRST_TITLE)
    bylaw_table_rows = bylaw_table.rows[2..-1] # First 2 rows are headers

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
    bylaw_table      = select_table(BYLAWS_PASSED_TITLE)
    bylaw_table_rows = bylaw_table.rows[2..-1] # First 2 rows are headers

    bylaw_table_rows.map do |bylaw_row|
      bylaw_builder(bylaw_row)
    end
  end

  # MOTIONS
  # All motions are assumed to be in a single table.
  # Motion subject may contain lists and other formatting, currently
  # this markup is ignore and converted to text only.

  def motions_collection
    motion_table      = select_table(COUNCIL_MOTIONS_TITLE)
    motion_table_rows = motion_table.rows[2..-1] # First 2 rows are headers

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

  # NOTICE OF MOTIONS
  # All motions are assumed to be in a single table.
  # Motion subject may contain lists and other formatting, currently
  # this markup is ignore and converted to text only.

  def notice_of_motions_collection
    motion_table      = select_table(NOTICE_OF_MOTION_TITLE)
    motion_table_rows = motion_table.rows[2..-1] # First 2 rows are headers

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

  # REPORTS
  # Unlike motions or bylaws, reports are stored in multiple tables.
  # The reports collection will be an array of hashes.
  # Each hash has a report title and an array of report items.

  def reports_collection
    report_tables = select_tables(REPORT_TITLE)

    report_tables.map do |report_table|
      { title: report_table.rows[0].cells[0].text,
        items: report_items(report_table) }
    end
  end

  def report_items(report_table)
    item_rows = report_table.rows[1..-1] # Skip the first title row.

    item_rows.map do |item_row|
      report_item_builder(item_row)
    end
  end

  def report_item_builder(item_row)
    item_columns = row_cells_to_text_columns(item_row)

    { number: item_columns[0],
      title: item_columns[1],
      disposition: item_columns[2] }
  end

  # RECORDED VOTES
  # Includes a title row.

  # TODO: Does this title contain a typo? Should RECORDS be REPORTS?
  #       Forth word wildcarded 7 letters starting with R to support both.
  RECORDED_VOTES_TITLE = /RECORDED VOTES FOR R......, MOTIONS AND BY-LAWS/

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

  def recorded_votes_collection
    recorded_votes_table = select_table(RECORDED_VOTES_TITLE)

    # First 2 rows are headers, so [2..-1]
    recorded_votes_table_rows = recorded_votes_table.rows[2..-1]

    recorded_votes_table_rows.map do |recorded_votes_row|
      recorded_votes_builder(recorded_votes_row)
    end
  end

  def recorded_votes_builder(votes_row)
    votes_columns = row_cells_to_text_columns(votes_row)

    {
      subject: votes_columns[0],
      disposition: votes_columns[3],
      yeas: cell_paragraphs(votes_row.cells[1]),
      nays: cell_paragraphs(votes_row.cells[2])
    }
  end

  # CONFLICT OF INTEREST DECLARATIONS

  DECLARATIONS_TITLE = /CONFLICT OF INTEREST DECLARATIONS/

  def conflict_of_interest_declarations_collection
    declaration_table = select_table(DECLARATIONS_TITLE)

    # First 2 rows are headers, so [2..-1]
    declaration_table_rows = declaration_table.rows[2..-1]

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
    end # Add an || here to replace nils with structs with 'rows' prop set to []
  end

  # Find the first table in the document where the top/left
  # cell text matches a given regexp.
  # Returns a single table.
  def select_table(heading_regexp)
    tables.find do |t|
      heading_regexp.match(t.rows[0].cells[0].text)
    end
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
