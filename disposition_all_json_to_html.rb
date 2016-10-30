require './file_helpers.rb'
require './erb_binding.rb'
require './disposition_presenter.rb'

# rubocop:disable Metrics/LineLength

if ARGV.size != 4
  puts 'Missing required arguments.'
  puts 'Example: #{$PROGRAM_NAME} disposition_template index_template input_folder output_folder'
  exit
end

erb_template = erb_template_from_file(ARGV[0])
index_erb_template = erb_template_from_file(ARGV[1])
input_folder = ARGV[2]
output_folder = ARGV[3]

disposition_meta = {
  '2015-09-30' => { 'youtube' => 'QXbU0ln7lo8', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=14677&SectionId=&InitUrl=' },
  '2015-10-28' => { 'youtube' => 'dZ2pS4zb7Cs', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=14759&SectionId=&InitUrl=' },
  '2015-11-25' => { 'youtube' => 'n3-lp7synvo', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=14855&SectionId=&InitUrl=' },
  '2015-12-09' => { 'youtube' => '9vuFasdioUs', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=14903&SectionId=&InitUrl=' },
  '2016-02-24' => { 'youtube' => 'Rd4ByL6C4pM', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15073&SectionId=&InitUrl=' },
  '2016-03-23' => { 'youtube' => 'TDIRkMT2_N0', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15162&SectionId=&InitUrl=' },
  '2016-04-27' => { 'youtube' => 'kj7N7cmnktg', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15242&SectionId=&InitUrl=' },
  '2016-05-18' => { 'youtube' => 'fAsou9J29no', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15306&SectionId=&InitUrl=' },
  '2016-06-15' => { 'youtube' => 'mfyigVDfy_s', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15382&SectionId=&InitUrl=' },
  '2016-07-13' => { 'youtube' => 'OCK3nx5PQYo', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15468&SectionId=&InitUrl=' },
  '2016-09-28' => { 'youtube' => 'fXQYVzhJgVY', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15468&SectionId=&InitUrl=' }
}

all_dispositions = []

def date_to_json_url(date)
  "https://github.com/OpenDemocracyManitoba/Winnipeg-Council-Document-Parser/blob/master/json_dispositions/DISPOSITION-#{date}.json"
end

# rubocop:enable Metrics/LineLength

disposition_meta.each do |date, meta|
  json_file   = "#{input_folder}/DISPOSITION-#{date}.json"
  html_file   = "#{output_folder}/disposition-#{date}.html"

  disposition_hash = json_disposition_from_file(json_file)

  # Inject Metadata
  disposition_hash.merge!(meta)
  disposition_hash['source_json'] = date_to_json_url(date)
  disposition = DispositionPresenter.new(disposition_hash)
  all_dispositions << disposition

  generated_html = ErbBinding.new(erb_template: erb_template,
                                  data_to_bind: disposition)

  File.open(html_file, 'w:UTF-8') do |f|
    f.write(generated_html.render)
  end
end

index_html_file = "#{output_folder}/index.html"
generated_html  = ErbBinding.new(erb_template: index_erb_template,
                                 data_to_bind: all_dispositions.reverse)

File.open(index_html_file, 'w:UTF-8') do |f|
  f.write(generated_html.render)
end
