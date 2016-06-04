# frozen_string_literal: true
require 'spec_helper'

describe DispositionFeed do
  FEED_PATH = File.dirname(__FILE__) +
              '/fixtures/disposition_feed.json'.freeze

  MALFORMED_FEED_PATH = File.dirname(__FILE__) +
                        '/fixtures/disposition_feed_malformed.json'.freeze

  context 'with a well-formed Disposition Feed JSON file' do
    subject(:disposition_feed) { DispositionFeed.new(FEED_PATH) }

    it 'should be the correct type' do
      expect(disposition_feed.class).to eq(DispositionFeed)
    end

    it 'should identify the correct number of regular dispositions' do
      expect(disposition_feed.regular_dispositions.size).to eq(5)
    end

    it 'should identify the correct number of special dispositions' do
      expect(disposition_feed.special_dispositions.size).to eq(2)
    end

    it 'should be able to provide access to meeting data by name' do
      # rubocop:disable Metrics/LineLength
      meeting = disposition_feed.regular_dispositions.first
      expect(meeting[:row]).to          eq(1)
      expect(meeting[:id]).to           eq('4E4B0D84-3493-40CC-8585-578C7A118A34')
      expect(meeting[:meeting_date]).to eq('2015-09-30T00:00:00')
      expect(meeting[:type]).to         eq('Regular Meeting')
      expect(meeting[:url]).to          eq('https://data.winnipeg.ca/download/jfmn-ak46/application/msword')
      expect(meeting[:publish_date]).to eq('2015-09-30T00:00:00')
      expect(meeting[:update_date]).to  eq('2015-09-30T00:00:00')
      # rubocop:enable Metrics/LineLength
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
