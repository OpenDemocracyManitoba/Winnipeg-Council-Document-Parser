# frozen_string_literal: true

require 'spec_helper'

describe DispositionFeed do
  FEED_PATH = File.dirname(__FILE__) +
              '/fixtures/disposition_feed.json'

  MALFORMED_FEED_PATH = File.dirname(__FILE__) +
                        '/fixtures/disposition_feed_malformed.json'

  context 'with a well-formed Disposition Feed JSON file' do
    subject(:disposition_feed) { DispositionFeed.new(FEED_PATH) }

    it 'should be the correct type' do
      expect(disposition_feed.class).to eq(DispositionFeed)
    end

    it 'should identify the correct number of regular dispositions' do
      expect(disposition_feed.regular_dispositions.size).to eq(47)
    end

    it 'should identify the correct number of special dispositions' do
      expect(disposition_feed.special_dispositions.size).to eq(9)
    end

    it 'should be able to provide access to meeting data by name' do
      meeting = disposition_feed.regular_dispositions.first
      expect(meeting[:meeting_date]).to eq('2020-01-30T00:00:00.000')
      expect(meeting[:type]).to         eq('Regular Meeting')
      expect(meeting[:url]).to          eq('https://data.winnipeg.ca/download/kc4f-2bge/application%2Fvnd.openxmlformats-officedocument.wordprocessingml.document')
    end
  end

  context 'with a malformed Disposition Feed JSON file' do
    it 'should raise a JSON Parser error' do
      expect do
        DispositionFeed.new(MALFORMED_FEED_PATH)
      end.to raise_error(JSON::ParserError)
    end
  end
end
