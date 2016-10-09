
if ARGV.size != 2
  puts 'Missing required arguments.'
  puts 'Example: #{$PROGRAM_NAME} input_folder output_folder'
  exit
end

input_folder = ARGV[0]
output_folder = ARGV[1]

disposition_meta = {
  '2015-09-30' => { youtube: 'QXbU0ln7lo8', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=14677&SectionId=&InitUrl=' },
  '2015-10-28' => { youtube: 'dZ2pS4zb7Cs', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=14759&SectionId=&InitUrl=' },
  '2015-11-25' => { youtube: 'n3-lp7synvo', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=14855&SectionId=&InitUrl=' },
  '2015-12-09' => { youtube: '9vuFasdioUs', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=14903&SectionId=&InitUrl=' },
  '2016-02-24' => { youtube: 'Rd4ByL6C4pM', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15073&SectionId=&InitUrl=' },
  '2016-03-23' => { youtube: 'TDIRkMT2_N0', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15162&SectionId=&InitUrl=' },
  '2016-04-27' => { youtube: 'kj7N7cmnktg', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15242&SectionId=&InitUrl=' },
  '2016-05-18' => { youtube: 'fAsou9J29no', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15306&SectionId=&InitUrl=' },
  '2016-06-15' => { youtube: 'mfyigVDfy_s', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15382&SectionId=&InitUrl=' },
  '2016-07-13' => { youtube: 'OCK3nx5PQYo', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15468&SectionId=&InitUrl=' }
  #'2016-09-28' => { youtube: 'fXQYVzhJgVY', dmis: 'http://clkapps.winnipeg.ca/dmis/ViewDoc.asp?DocId=15468&SectionId=&InitUrl=' },
}

