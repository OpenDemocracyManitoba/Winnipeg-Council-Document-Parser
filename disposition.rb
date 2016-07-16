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
# - Attendance scraping. (Council and Public Servant)
# - Recorded votes scraping. Sometimes not present.
# - Conflict of interest declaration scraping. Often not present.
# - Implement first reading bylaw scraping. Often not present.
# - Implement notice of motion scraping. Often not present.

class Disposition
  # Table Headers Used for Dispositoin Extraction
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

  def motions
    motions_collection
  end

  def reports
    reports_collection
  end

  private

  # BYLAWS PASSED
  # Bylaws are assumed to be stored in a single table.

  def bylaws_passed_collection
    bylaw_table      = select_table(BYLAWS_PASSED_HEADER)
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

  # MOTIONS
  # All motions are assumed to be in a single table.
  # Many motion subjects contain lists and other formatting, currently
  # this markup is ignore and converted to text only.

  def motions_collection
    motion_table      = select_table(COUNCIL_MOTIONS_HEADER)
    motion_table_rows = motion_table.rows[2..-1] # First 2 rows are headers

    motion_table_rows.map do |motion_row|
      motion_builder(motion_row)
    end
  end

  def motion_builder(motion_row)
    motion_columns = row_cells_to_text_columns(motion_row)

    { number:      motion_columns[0],
      movers:      split_and_title_movers(motion_columns[1]),
      subject:     motion_columns[2],
      disposition: motion_columns[3] }
  end

  def split_and_title_movers(movers_text)
    movers_text.split('/').map do |mover|
      "Councillor #{mover}"
    end
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
