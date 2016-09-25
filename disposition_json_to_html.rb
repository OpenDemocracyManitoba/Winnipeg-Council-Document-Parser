require './file_helpers.rb'
require './erb_binding.rb'
require './hansard.rb'

if ARGV.size != 2
  puts 'Missing required arguments.'
  puts "Example: #{$PROGRAM_NAME} input.json template.erb"
  exit
end

json_hansard   = json_hansard_from_file(ARGV[0])
erb_template   = erb_template_from_file(ARGV[1])
stop_words     = stopwords_from_file('./stopwords.txt')

hansard        = Hansard.new(json_hansard: json_hansard,
                             stop_words:   stop_words)

generated_html = ErbBinding.new(erb_template: erb_template,
                                data_to_bind: hansard)

puts generated_html.render
