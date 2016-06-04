require 'json'
require 'date'

class DispositionFeed
  def initialize(feed_path)
    feed_file = File.open(feed_path, 'r:UTF-8')
    @feed_json = JSON.parse(feed_file.read)
  end

  def regular_dispositions
    dispositions.select do |disposition|
      disposition[:type] == 'Regular Meeting'
    end
  end

  def special_dispositions
    dispositions.select do |disposition|
      disposition[:type] == 'Special Meeting'
    end
  end

  private

  # Data mapping for the JSON served by data.winnipeg.ca listing all
  # disposition Word doc available for download.
  #
  # The JSON has two high-level keys, 'meta' and 'data'. We are only
  # interested in the 'data' array, which is the array of documents.
  def dispositions
    @feed_json['data'].map do |disposition|
      { row:          disposition[0],
        id:           disposition[1],
        meeting_date: disposition[8],
        type:         disposition[9],
        url:          disposition[10][0],
        publish_date: disposition[11],
        update_date:  disposition[12] }
    end
  end
end
