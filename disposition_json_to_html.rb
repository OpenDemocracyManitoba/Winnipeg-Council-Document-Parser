require './file_helpers.rb'
require './erb_binding.rb'
require './disposition_presenter.rb'

if ARGV.size != 2
  puts 'Missing required arguments.'
  puts "Example: #{$PROGRAM_NAME} input.json template.erb"
  exit
end

disposition  = DispositionPresenter.new(json_disposition_from_file(ARGV[0]))
erb_template = erb_template_from_file(ARGV[1])

generated_html = ErbBinding.new(erb_template: erb_template,
                                data_to_bind: disposition)

puts generated_html.render
