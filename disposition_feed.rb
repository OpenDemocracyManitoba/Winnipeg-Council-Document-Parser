require 'json'

class DispositionFeed
  def initialize(feed_path)
    feed_file = File.open(feed_path, 'r:UTF-8')
    @feed_json = JSON.parse(feed_file.read)
  end
end
