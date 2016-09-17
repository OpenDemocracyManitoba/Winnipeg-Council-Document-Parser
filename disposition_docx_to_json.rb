# Script to convert DOCX dispositions into JSON.
# 
# Required command line argument: DOCX Dispoition Filename
#
# Generated JSON is sent to STDOUT.

require 'json'
require_relative 'disposition'

if ARGV.size != 1
  puts 'Missing required arguments.'
  puts "Example: #{$PROGRAM_NAME} some_disposition.docx"
  exit
end

docx_input_filepath = ARGV[0]
json_output_filepath = ARGV[1]

disposition = Disposition.new(docx_input_filepath)
puts JSON.pretty_generate(disposition.to_h)
