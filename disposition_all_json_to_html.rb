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
  '2016-01-27' => { 'youtube' => 'aNf_To3cKag', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15003&SectionId=&InitUrl=' },
  '2016-02-24' => { 'youtube' => 'Rd4ByL6C4pM', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15073&SectionId=&InitUrl=' },
  '2016-03-23' => { 'youtube' => 'TDIRkMT2_N0', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15162&SectionId=&InitUrl=' },
  '2016-04-27' => { 'youtube' => 'kj7N7cmnktg', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15242&SectionId=&InitUrl=' },
  '2016-05-18' => { 'youtube' => 'fAsou9J29no', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15306&SectionId=&InitUrl=' },
  '2016-06-15' => { 'youtube' => 'mfyigVDfy_s', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15382&SectionId=&InitUrl=' },
  '2016-07-13' => { 'youtube' => 'OCK3nx5PQYo', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15468&SectionId=&InitUrl=' },
  '2016-09-28' => { 'youtube' => 'fXQYVzhJgVY', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15578&SectionId=&InitUrl=' },
  '2016-10-26' => { 'youtube' => 'smtUoXfVdMI', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15661&SectionId=&InitUrl=' },
  '2016-11-16' => { 'youtube' => 'ZkejgGTnNWk', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15721&SectionId=&InitUrl=' },
  '2016-12-14' => { 'youtube' => '4yGGgD-cYTk', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15803&SectionId=&InitUrl=' },
  '2017-01-25' => { 'youtube' => 'nhBNBCGPqUM', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15885&SectionId=&InitUrl=' },
  '2017-02-22' => { 'youtube' => '1KJYCUJpw5s', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15955&SectionId=&InitUrl=' },
  '2017-03-22' => { 'youtube' => 'vRi7SF5gB5w', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16026&SectionId=&InitUrl=' },
  '2017-04-26' => { 'youtube' => 'c1A7_mN4vkg', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16111&SectionId=&InitUrl=' },
  '2017-05-24' => { 'youtube' => 'VAlD6ZVODUY', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16185&SectionId=&InitUrl=' },
  '2017-06-21' => { 'youtube' => 'Pz0tWWLcqoY', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16253&SectionId=&InitUrl=' },
  '2017-07-19' => { 'youtube' => 'HgXfEv40f6Y', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16340&SectionId=&InitUrl=' },
  '2017-09-27' => { 'youtube' => 'iFAVI-TxQh0', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16433&SectionId=&InitUrl=' },
  '2017-10-25' => { 'youtube' => 'yZxmOh9Ccwg', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16516&SectionId=&InitUrl=' },
  '2017-11-15' => { 'youtube' => 'v1LX_GQBlgM', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16571&SectionId=&InitUrl=' },
  '2017-12-13' => { 'youtube' => 'pBzo3FDIg8E', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16669&SectionId=&InitUrl=' },
  '2018-01-25' => { 'youtube' => '', 'dmis' => 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=16764&SectionId=&InitUrl=' }
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
