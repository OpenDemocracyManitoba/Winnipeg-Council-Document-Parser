require 'open-uri'
require_relative 'disposition_feed'

FEED_URL = 'https://data.winnipeg.ca/api/views/hsbq-sj6t/rows.json?accessType=DOWNLOAD'
TEMP_FEED_FILE = 'temporary_feed.json'

def download_file(url, save_file, binary = false)
  read_mode = binary ? 'rb' : 'r'
  write_mode = binary ? 'wb' : 'w'
  File.open(save_file, write_mode) do |saved_feed|
    open(url, read_mode) do |feed|
      saved_feed.write(feed.read)
    end
  end
end

download_file(FEED_URL, TEMP_FEED_FILE)

parsed_disposition_feed = DispositionFeed.new(TEMP_FEED_FILE)
regular_dispositions = parsed_disposition_feed.regular_dispositions

regular_dispositions.each do |disposition|
  date = disposition[:meeting_date][0..9]
  save_file = "DISPOSITION-#{date}.docx"
  puts "Downloading #{save_file}"
  download_file(disposition[:url], save_file)
end

if File.exists?(TEMP_FEED_FILE)
  File.delete(TEMP_FEED_FILE)
end

