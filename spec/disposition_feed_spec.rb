# frozen_string_literal: true
require 'spec_helper'

FEED_FIXTURE = File.dirname(__FILE__) + '/fixtures/disposition_feed.json'.freeze

describe DispositionFeed do
  subject(:disposition_feed) { DispositionFeed.new(FEED_FIXTURE) }

  it 'should be the correct type' do
    expect(disposition_feed.class).to eq(DispositionFeed)
  end
end
