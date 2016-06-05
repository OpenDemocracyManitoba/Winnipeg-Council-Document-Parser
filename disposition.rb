# frozen_string_literal: true
require 'docx'
require 'forwardable'

class Disposition
  extend Forwardable

  def initialize(filename)
    @doc = Docx::Document.open(filename)
  end

  def bylaws_passed
    bylaws_collection
  end

  def motions
    motions_collection
  end

  def reports
    reports_collection
  end

  private

  attr_reader :doc
  def_delegator :doc, :tables # Why isn't this delegator private?

  # BYLAWS

  BYLAWS_PASSED_HEADER = 'BY-LAWS PASSED (RECEIVED THIRD READING)'.freeze

  def bylaw_table
    select_table(BYLAWS_PASSED_HEADER)
  end

  def bylaws_collection
    bylaw_table_rows = bylaw_table.rows[2..-1] # First 2 rows are headers
    bylaw_table_rows.map do |bylaw_row|
      bylaw_builder(bylaw_row)
    end
  end

  def bylaw_builder(bylaw_row)
    bylaw_columns = table_row_columns(bylaw_row)

    { number:      bylaw_columns[0],
      subject:     bylaw_columns[1],
      disposition: bylaw_columns[2] }
  end

  # MOTIONS
  #
  # * Motion table in document cannot be broken into multiple tables.
  # * Many motion subjects contain lists and other formatting,
  # * currently this is ignore and converted to text only.

  MOTIONS_HEADER = 'COUNCIL MOTIONS'.freeze

  def motion_table
    select_table(MOTIONS_HEADER)
  end

  def motions_collection
    motion_table_rows = motion_table.rows[2..-1] # First 2 rows are headers
    motion_table_rows.map do |motion_row|
      motion_builder(motion_row)
    end
  end

  def motion_builder(motion_row)
    motion_columns = table_row_columns(motion_row)

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

  def report_tables
    select_tables(/^REPORT/)
  end

  def reports_collection
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
    item_columns = table_row_columns(item_row)

    { number: item_columns[0],
      title: item_columns[1],
      disposition: item_columns[2] }
  end

  # HELPERS

  def select_tables(heading_regexp)
    tables.select do |t|
      heading_regexp.match(t.rows[0].cells[0].text)
    end
  end

  def select_table(heading)
    tables.find do |t|
      t.rows[0].cells[0].text == heading
    end
  end

  def table_row_columns(table_row)
    table_row.cells.map do |cell|
      cell.text.strip
    end
  end
end
