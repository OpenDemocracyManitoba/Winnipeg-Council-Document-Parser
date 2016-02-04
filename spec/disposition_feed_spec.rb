# frozen_string_literal: true
require 'spec_helper'

FEED_FIXTURE = File.dirname(__FILE__) +
               '/fixtures/disposition_feed.json'.freeze
MALFORMED_FEED_FIXTURE = File.dirname(__FILE__) +
                         '/fixtures/disposition_feed_malformed.json'.freeze

describe DispositionFeed do
  context 'with a well-formed Disposition Feed JSON file' do
    subject(:disposition_feed) { DispositionFeed.new(FEED_FIXTURE) }

    it 'should be the correct type' do
      expect(disposition_feed.class).to eq(DispositionFeed)
    end
  end

  context 'with a malformed Disposition Feed JSON file' do
    it 'should raise a JSON Parser error' do
      expect do
        DispositionFeed.new(MALFORMED_FEED_FIXTURE)
      end.to raise_error(JSON::ParserError)
    end
  end
end
