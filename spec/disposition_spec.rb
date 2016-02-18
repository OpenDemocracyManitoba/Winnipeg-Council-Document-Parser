require 'spec_helper'

describe Disposition do
  DISPOSITION_PATH = File.dirname(__FILE__) +
                     '/fixtures/DISPOSITION-2015-09-03.docx'

  context 'when working with a disposition that include bylaw' do
    subject(:disposition) do
      Disposition.new(DISPOSITION_PATH)
    end

    it 'should instantiate as an object' do
      expect(disposition.class).to eq(Disposition)
    end

    it 'should locate the correct number of bylaws passed' do
      expect(disposition.bylaws.size).to eq(16)
    end

    it 'should correctly identify the first passed bylaw' do
      # rubocop:disable Metrics/LineLength
      first_bylaw = { number:      '43/2015',
                      subject:     'To amend the North Henderson Highway Secondary Plan By-law No. 1300/1976 – SPA 1/2015',
                      disposition: 'PASSED' }
      # rubocop:enable Metrics/LineLength
      expect(disposition.bylaws.first).to eq(first_bylaw)
    end
  end

  context 'when working with a disposition that include motions' do
    subject(:disposition) do
      Disposition.new(DISPOSITION_PATH)
    end

    it 'should locate the correct number of motions' do
      expect(disposition.motions.size).to eq(13)
    end

    it 'should correctly identity the third motion' do
      # 3rd motion selected for it's brevity.
      # rubocop:disable Metrics/LineLength
      third_motion = { number:      '3',
                       movers:      ['Councillor Eadie', 'Councillor Allard'],
                       subject:     'That the Winnipeg public service look to other Canadian cities for cannabis regulatory provisions in order to establish limits on cannabis related facilities in Winnipeg.',
                       disposition: 'AUTOMATIC REFERRAL TO THE STANDING POLICY COMMITTEE ON PROPERTY AND DEVELOPMENT' }
      # rubocop:enable Metrics/LineLength
      expect(disposition.motions[2]).to eq(third_motion)
    end
  end
end
