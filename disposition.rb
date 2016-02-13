require 'docx'
require 'forwardable'

class Disposition
  extend Forwardable

  def initialize(filename)
    @doc = Docx::Document.open(filename)
  end

  def bylaws
    bylaws_collection
  end

  def motions
    motions_collection
  end

  private

  attr_reader :doc
  def_delegator :doc, :tables # Why isn't this delegator private?

  # BYLAWS

  def bylaw_table
    table_select('BY-LAWS PASSED (RECEIVED THIRD READING)')
  end

  def bylaw_table_rows
    bylaw_table.rows[2..-1] # The first two rows are headers
  end

  def bylaws_collection
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

  def motion_table
    table_select('COUNCIL MOTIONS')
  end

  def motion_table_rows
    motion_table.rows[2..-1] # The first two rows are headers
  end

  def motions_collection
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

  # HELPERS

  def table_select(heading)
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
