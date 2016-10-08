require './file_helpers.rb'
require './erb_binding.rb'

if ARGV.size != 2
  puts 'Missing required arguments.'
  puts "Example: #{$PROGRAM_NAME} input.json template.erb"
  exit
end

disposition  = json_disposition_from_file(ARGV[0])
erb_template = erb_template_from_file(ARGV[1])

generated_html = ErbBinding.new(erb_template: erb_template,
                                data_to_bind: disposition)

puts generated_html.render
