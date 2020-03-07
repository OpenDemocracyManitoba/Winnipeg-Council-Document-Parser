# frozen_string_literal: true

require 'open-uri'
require 'optparse'
require_relative 'disposition_feed'

FEED_URL = 'https://data.winnipeg.ca/resource/hsbq-sj6t.json'
TEMP_FEED_FILE = 'temporary_feed.json'

def download_file(url, save_file)
  File.open(save_file, 'w') do |saved_feed|
    File.open(url, 'r') do |feed|
      saved_feed.write(feed.read)
    end
  end
end

options = { testmode: false, latestonly: false, folder: '.' }

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"
  opts.separator 'Downloads disposition documents from data.winnipeg.ca.'
  opts.separator 'Options:'
  opts.on('-t', '--testmode', 'Test only. Does not download files.') do |t|
    options[:testmode] = t
  end
  opts.on('-l', '--latestonly', 'Do not overwrite existing files.') do |l|
    options[:latestonly] = l
  end
  opts.on('-f', '--folder FOLDER', 'Specify a download folder.') do |f|
    options[:folder] = f
  end
end.parse!

download_file(FEED_URL, TEMP_FEED_FILE)

parsed_disposition_feed = DispositionFeed.new(TEMP_FEED_FILE)
regular_dispositions = parsed_disposition_feed.regular_dispositions

puts 'Test Mode: No downloads' if options[:testmode]

regular_dispositions.each do |disposition|
  date = disposition[:meeting_date][0..9]
  save_file = File.join(options[:folder], "DISPOSITION-#{date}.docx")
  if options[:latestonly] && File.exist?(save_file)
    puts "Skipping existing copy of #{save_file}"
  else
    puts "Downloading #{save_file}"
    download_file(disposition[:url], save_file) unless options[:testmode]
  end
end

File.delete(TEMP_FEED_FILE) if File.exist?(TEMP_FEED_FILE)
