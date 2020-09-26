require 'rubygems'
require 'bundler/setup'
require 'docx'
require 'pp'
require 'date'

paths = []
paths << File.join(File.dirname(__FILE__), 'spec/fixtures/DISPOSITION-2015-09-30.docx')
paths << File.join(File.dirname(__FILE__), 'spec/fixtures/DISPOSITION-2016-04-27.docx')
paths << File.join(File.dirname(__FILE__), 'spec/fixtures/DISPOSITION-2016-07-13.docx')
paths << File.join(File.dirname(__FILE__), 'word_dispositions/DISPOSITION-2019-12-12.docx')
paths << File.join(File.dirname(__FILE__), 'word_dispositions/DISPOSITION-2020-01-30.docx')

def find_date(path)
  doc = Docx::Document.open(path)

  puts "Paragraphs: #{doc.paragraphs.size}"

  first_table = doc.tables.first

  puts "First Table Rows: #{first_table.row_count}"
  puts "First Table Columns: #{first_table.column_count}"

  paras = first_table.rows[0].cells[0].paragraphs

  puts "Found #{paras.size} paragraphs."

  date = paras[0..20].map do |paragraph|
    # Exceptional handling as validator. :S
    Date.parse(paragraph.text)
  rescue ArgumentError
    nil
  end.compact.first

  date
end

paths.each do |path|
  puts find_date(path)
end
