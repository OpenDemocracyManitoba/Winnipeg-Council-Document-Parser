require 'json'
require 'date'

class DispositionFeed
  def initialize(feed_path)
    feed_file = File.open(feed_path, 'r:UTF-8')
    @feed_json = JSON.parse(feed_file.read)
    feed_file.close
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
  # disposition Word docs available for download.
  def dispositions
    @feed_json.map do |disposition|
      { meeting_date: disposition['meeting_date'],
        type:         disposition['meeting_type'],
        url:          disposition['document_link']['url'] }
    end
  end
end
