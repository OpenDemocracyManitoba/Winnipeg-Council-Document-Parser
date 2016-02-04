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
  end

  context 'with a malformed Disposition Feed JSON file' do
    it 'should raise a JSON Parser error' do
      expect do
        DispositionFeed.new(MALFORMED_FEED_PATH)
      end.to raise_error(JSON::ParserError)
    end
  end
end
