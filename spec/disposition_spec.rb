# rubocop:disable Metrics/LineLength
require 'spec_helper'

# FIXTURES
# ========
#
# - DISPOSITION-2015-09-30.docx (Septerber 30, 2015)
#   + Attendance (15 Counil Members, 5 Public Service)
#   + Reports (7)
#   + Notice of Motions (Not Present)
#   + Motions (13)
#   + Bylaws 1st Reading (3)
#   + Bylaws 3rd Reading (16)
# - DISPOSITION-2016-04-27.docx (April 27, 2016)
#   + Notice of Motions (1)
#   + Bylaws 1st Reading (Not Present)
#   + Recorded Votes (5)
#   + Conflict of Interest Declaration (Not Present)
# - DISPOSITION-2016-07-13.docx (July 13, 2016)
#   + Conflict of Interest Declaration (1)
#

class DispositionFixture
  def self.path(iso_date) # YYYY-MM-DD
    filename = "DISPOSITION-#{iso_date}.docx"
    File.join(File.dirname(__FILE__), 'fixtures', filename)
  end

  def self.fixtures(name)
    {
      with_attendance_reports_motions_bylaws: path('2015-09-30'),

      with_conflict_of_interest:    path('2016-07-13'),
      with_recorded_votes:          path('2016-04-27'),
      with_notice_of_motions:       path('2016-04-27'),
      # Without testing required?
    }[name]
  end
end

describe Disposition do
  context 'when the disposition incluces conflict of interest declarations' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_conflict_of_interest))
    end

    it 'should instantiate as an object' do
      expect(disposition.class).to eq(Disposition)
    end
  end

  context 'when the disposition incluces recorded votes' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_recorded_votes))
    end

    it 'should instantiate as an object' do
      expect(disposition.class).to eq(Disposition)
    end
  end

  context 'when the disposition includes notice of motions' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_notice_of_motions))
    end

    it 'should instantiate as an object' do
      expect(disposition.class).to eq(Disposition)
    end
  end

  context 'when the disposition includes 1st reading bylaws' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_attendance_reports_motions_bylaws))
    end

    it 'should instantiate as an object' do
      expect(disposition.class).to eq(Disposition)
    end

    # it 'should locate the correct number of 1st reading bylaws' do
      # expect(disposition.bylaws_passed.size).to eq(16)
    # end

    # it 'should correctly identify the first of the 1st reading bylaws' do
      # first_bylaw = { number:      '',
                      # subject:     '',
                      # disposition: '' }
      # expect(disposition.bylaws_passed.first).to eq(first_bylaw)
    # end
  end

  context 'when the disposition includes bylaws 3rd reading' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_attendance_reports_motions_bylaws))
    end

    it 'should locate the correct number of bylaws passed' do
      expect(disposition.bylaws_passed.size).to eq(16)
    end

    it 'should correctly identify the first passed bylaw' do
      first_bylaw = { number:      '43/2015',
                      subject:     'To amend the North Henderson Highway Secondary Plan By-law No. 1300/1976 – SPA 1/2015',
                      disposition: 'PASSED' }
      expect(disposition.bylaws_passed.first).to eq(first_bylaw)
    end
  end

  context 'when the disposition includes motions' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_attendance_reports_motions_bylaws))
    end

    it 'should locate the correct number of motions' do
      expect(disposition.motions.size).to eq(13)
    end

    it 'should correctly identity the third motion' do
      # 3rd motion selected for it's brevity.
      third_motion = { number:      '3',
                       movers:      ['Councillor Eadie', 'Councillor Allard'],
                       subject:     'That the Winnipeg public service look to other Canadian cities for cannabis regulatory provisions in order to establish limits on cannabis related facilities in Winnipeg.',
                       disposition: 'AUTOMATIC REFERRAL TO THE STANDING POLICY COMMITTEE ON PROPERTY AND DEVELOPMENT' }
      expect(disposition.motions[2]).to eq(third_motion)
    end
  end

  context 'when the disposition includes reports' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_attendance_reports_motions_bylaws))
    end

    it 'should locate the correct number of reports' do
      expect(disposition.reports.size).to eq(7)
    end

    it 'should correctly identity the title of the first report' do
      first_report = disposition.reports.first
      expect(first_report[:title]).to eq('REPORT OF THE EXECUTIVE POLICY COMMITTEE dated September 16, 2015')
    end

    it 'should identity the correct number of items in the first report' do
      first_report = disposition.reports.first
      expect(first_report[:items].size).to eq(7)
    end

    it 'should identity the title of the first item of the first report' do
      first_report = disposition.reports.first
      first_item   = first_report[:items].first
      expect(first_item[:title]).to eq('CentreVenture Development Corporation – Long-term Funding Solution')
    end

    it 'should identity the disposition of the first item of the first report' do
      first_report = disposition.reports.first
      first_item   = first_report[:items].first
      expect(first_item[:disposition]).to eq('60 DAY EXTENSION OF TIME GRANTED')
    end

    it 'should identity the number of the first item of the first report' do
      first_report = disposition.reports.first
      first_item   = first_report[:items].first
      expect(first_item[:number]).to eq('1')
    end
  end
end

# rubocop:enable Metrics/LineLength
