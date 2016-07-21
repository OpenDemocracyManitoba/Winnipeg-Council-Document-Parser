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
# - Recorded votes scraping. Sometimes not present.
# - Conflict of interest declaration scraping. Often not present.
# - 2016-04-27 fixture: Fix table connection between motions and passed bylaws.
# - Null Objects or Empty Arrays needed for public API for optional sections?

class Disposition
  # Table Headers Used for Dispositoin Extraction
  ATTENDANCE_HEADER       = 'MEMBERS PRESENT'.freeze
  BYLAWS_PASSED_HEADER    = 'BY-LAWS PASSED (RECEIVED THIRD READING)'.freeze
  BYLAWS_FIRST_HEADER     = 'BY-LAWS RECEIVING FIRST READING ONLY'.freeze
  COUNCIL_MOTIONS_HEADER  = 'COUNCIL MOTIONS'.freeze
  NOTICE_OF_MOTION_HEADER = 'NOTICE OF MOTION'.freeze
  REPORT_HEADER_REGEXP    = /^REPORT/

  # Dispositions are built from a path to a docx disposition document.
  def initialize(docx_file_path)
    # Use the private getter to access @doc within this class.
    @doc = Docx::Document.open(docx_file_path)
  end

  # Public API (Written as one-liners to read like a table of contents.)

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

  # Extracted disposition as hash.
  def to_h
    {
      bylaws_passed:        bylaws_passed,
      bylaws_first_reading: bylaws_first_reading,
      motions:              motions,
      reports:              reports,
      attendance:           attendance_collection
    }
  end

  private

  # ATTENDANCE
  # Single table with header row, but no title row.
  # First column is council attendance.
  # Second column is public service attendance.

  def attendance_collection
    attendance_table = select_table(ATTENDANCE_HEADER)
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
    bylaw_table      = select_table(BYLAWS_FIRST_HEADER)
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
    bylaw_table      = select_table(BYLAWS_PASSED_HEADER)
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
    motion_table      = select_table(COUNCIL_MOTIONS_HEADER)
    motion_table_rows = motion_table.rows[2..-1] # First 2 rows are headers

    motion_table_rows.map do |motion_row|
      motion_builder(motion_row)
    end
  end

  def split_and_title_movers(movers_text)
    movers_text.split('/').map(&:strip)
  end

  def motion_builder(motion_row)
    motion_columns = row_cells_to_text_columns(motion_row)

    { number:      motion_columns[0],
      movers:      split_and_title_movers(motion_columns[1]),
      subject:     motion_columns[2],
      disposition: motion_columns[3] }
  end

  # NOTICE OF MOTIONS
  # All motions are assumed to be in a single table.
  # Motion subject may contain lists and other formatting, currently
  # this markup is ignore and converted to text only.

  def notice_of_motions_collection
    motion_table      = select_table(NOTICE_OF_MOTION_HEADER)
    motion_table_rows = motion_table.rows[2..-1] # First 2 rows are headers

    motion_table_rows.map do |motion_row|
      notice_of_motion_builder(motion_row)
    end
  end

  def notice_of_motion_builder(motion_row)
    motion_columns = row_cells_to_text_columns(motion_row)

    { movers:      split_and_title_movers(motion_columns[0]),
      subject:     motion_columns[1],
      disposition: motion_columns[2] }
  end

  # REPORTS
  # Unlike motions or bylaws, reports are stored in multiple tables.
  # The reports collection will be an array of hashes.
  # Each hash has a report title and an array of report items.

  def reports_collection
    report_tables = select_tables(REPORT_HEADER_REGEXP)

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
  # cell text matches a given string.
  # Returns a single table.
  def select_table(heading)
    tables.find do |t|
      t.rows[0].cells[0].text == heading
    end
  end

  # Take a docx array of cells and convert into
  # an array of Strings built from the cell text.
  def row_cells_to_text_columns(table_row)
    table_row.cells.map do |cell|
      cell.text.strip
    end
  end
end
