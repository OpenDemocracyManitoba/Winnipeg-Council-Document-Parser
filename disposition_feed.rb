require 'json'
require 'date'

class DispositionFeed
  def initialize(feed_path)
    feed_file = File.open(feed_path, 'r:UTF-8')
    @feed_json = JSON.parse(feed_file.read)
  end

  def regular_meetings
    meetings.select { |meeting| meeting[:type] == 'Regular Meeting' }
  end

  def special_meetings
    meetings.select { |meeting| meeting[:type] == 'Special Meeting' }
  end

  private

  def meetings
    @feed_json['data'].map do |meeting|
      { row:          meeting[0],
        id:           meeting[1],
        meeting_date: Date.parse(meeting[8]),
        type:         meeting[9],
        url:          meeting[10][0],
        publish_date: Date.parse(meeting[11]),
        update_date:  Date.parse(meeting[12]) }
    end
  end
end
