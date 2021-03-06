# rubocop:disable Metrics/LineLength
require 'spec_helper'

# FIXTURES
# ========
#
# - DISPOSITION-2015-09-30.docx (Septerber 30, 2015)
#   + Attendance (15 Council Members, 5 Public Service)
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
      with_conflict_of_interest:              path('2016-07-13'),
      with_recorded_votes:                    path('2016-04-27'),
      with_notice_of_motions:                 path('2016-04-27'),
      without_conflict_of_interest:           path('2016-04-27'),
      without_recorded_votes:                 path('2016-07-13'),
      without_1st_reading_bylaws:             path('2016-04-27')
    }[name]
  end
end

describe Disposition do
  # ATTENDANCE
  # ----------

  context 'for all dispositions' do
    subject(:dispositions) do
      { '2015-09-30' => Disposition.new(DispositionFixture.path('2015-09-30')),
        '2016-04-27' => Disposition.new(DispositionFixture.path('2016-04-27')),
        '2016-07-13' => Disposition.new(DispositionFixture.path('2016-07-13')) }
    end

    it 'should identify the correct meeting date' do
      dispositions.each do |date, disposition|
        expect(disposition.meeting_date).to eq(Date.parse(date))
      end
    end
  end

  context 'when the disposition includes attendance' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_attendance_reports_motions_bylaws))
    end

    it 'should find the correct council attendance count' do
      in_attendance = disposition.attendance_council.size
      expect(in_attendance).to eq(15)
    end

    it 'should identify the first council member in attendance' do
      expect(disposition.attendance_council.first).to eq('His Worship Mayor Bowman')
    end

    it 'should find the correct public service attendance count' do
      in_attendance = disposition.attendance_public_service.size
      expect(in_attendance).to eq(5)
    end

    it 'should identify the first public servant in attendance' do
      expect(disposition.attendance_public_service.first).to eq('Mr. R. Kachur, City Clerk')
    end
  end

  # REPORTS
  # -------

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

    it 'should correctly identity the date of the first report' do
      first_report = disposition.reports.first
      expect(first_report[:date]).to eq(Date.parse('September 16, 2015'))
    end

    it 'should correctly identity the committee of the first report' do
      first_report = disposition.reports.first
      expect(first_report[:committee]).to eq('Executive Policy Committee')
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

  # NOTICE OF MOTIONS
  # -----------------

  context 'when the disposition includes notice of motions' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_notice_of_motions))
    end

    it 'should find the correct number of notice of motions' do
      expect(disposition.notice_of_motions.size).to eq(1)
    end

    it 'should identify the first motion' do
      first_motion = { movers:      %w[Schreyer Wyatt],
                       subject:     'THEREFORE BE IT RESOLVED THAT the City of Winnipeg request the Province of Manitoba to refer to the Public Utilities Board (PUB) and call public hearings on the following: A)The proposed Water and Sewer Rate Increases of 2016, 2017, and 2018; B)The approved  ‘dividend’ from the Water and Waste Department to the Operating/Capital Budget of the City of Winnipeg; C)The Capital Budget Program of Water and Waste, both 2016 Capital Budget and the 5 Year Forecast 2017 to 2021; D)The environmental regulatory obligations on the City of Winnipeg in regard to its Water and Waste systems; E)The Business Plans and all Capital project strategies/plans of the Water and Waste Department; F)Options for Provincial and Federal Funding of the regulatory capital program requirements.',
                       disposition: 'LOST' }
      expect(disposition.notice_of_motions.first).to eq(first_motion)
    end
  end

  # MOTIONS
  # -------

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
                       movers:      %w[Eadie Allard],
                       subject:     'That the Winnipeg public service look to other Canadian cities for cannabis regulatory provisions in order to establish limits on cannabis related facilities in Winnipeg.',
                       disposition: 'AUTOMATIC REFERRAL TO THE STANDING POLICY COMMITTEE ON PROPERTY AND DEVELOPMENT' }
      expect(disposition.motions[2]).to eq(third_motion)
    end
  end

  # BYLAWS 1ST READING
  # ------------------

  context 'when the disposition includes 1st reading bylaws' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_attendance_reports_motions_bylaws))
    end

    it 'should locate the correct number of 1st reading bylaws' do
      expect(disposition.bylaws_first_reading.size).to eq(3)
    end

    it 'should correctly identify the first of the 1st reading bylaws' do
      first_bylaw = { number:      '81/2015',
                      subject:     'To amend the North Henderson Highway Secondary Plan By-law No. 1300/1976. - SPA 4/2015',
                      disposition: 'RECEIVED FIRST READING ONLY' }
      expect(disposition.bylaws_first_reading.first).to eq(first_bylaw)
    end
  end

  context 'when the disposition does not include 1st reading bylaws' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:without_1st_reading_bylaws))
    end

    it 'should locate the correct number of 1st reading bylaws' do
      expect(disposition.bylaws_first_reading.size).to eq(0)
    end
  end

  # BYLAWS 3RD READING
  # ------------------

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

  # RECORDED VOTES
  # --------------

  context 'when the disposition includes recorded votes' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_recorded_votes))
    end

    it 'should find the correct recorded votes count' do
      recorded_votes = disposition.recorded_votes
      expect(recorded_votes.size).to eq(5)
    end

    it 'should find the subject of the first voting item' do
      recorded_votes = disposition.recorded_votes
      vote_subject = recorded_votes.first[:subject]
      expect(vote_subject).to eq('Motion 4 Schreyer / Wyatt')
    end

    it 'should find the disposition of the first voting item' do
      recorded_votes = disposition.recorded_votes
      vote_subject = recorded_votes.first[:disposition]
      expect(vote_subject).to eq('LOST')
    end

    it 'should find the correct YEAS count on the first voting item' do
      first_vote = disposition.recorded_votes.first
      yeas_count = first_vote[:yeas].size
      expect(yeas_count).to eq(5)
    end

    it 'should find the name of the first YEA on the first voting item' do
      first_vote = disposition.recorded_votes.first
      first_yea = first_vote[:yeas].first
      expect(first_yea).to eq('Councillor Allard')
    end

    it 'should find the name of the last YEA on the first voting item' do
      first_vote = disposition.recorded_votes.first
      first_yea = first_vote[:yeas].last
      expect(first_yea).to eq('Councillor Wyatt')
    end

    it 'should find the correct NAYS count on the first voting item' do
      first_vote = disposition.recorded_votes.first
      nays_count = first_vote[:nays].size
      expect(nays_count).to eq(11)
    end

    it 'should find the name of the first NAY on the first voting item' do
      first_vote = disposition.recorded_votes.first
      first_nay = first_vote[:nays].first
      expect(first_nay).to eq('His Worship Mayor Bowman')
    end

    it 'should find the name of the last NAY on the first voting item' do
      first_vote = disposition.recorded_votes.first
      first_nay = first_vote[:nays].last
      expect(first_nay).to eq('Councillor Sharma')
    end
  end

  context 'when the disposition does not include recorded votes' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:without_recorded_votes))
    end

    it 'should find the correct recorded votes count' do
      recorded_votes = disposition.recorded_votes
      expect(recorded_votes.size).to eq(0)
    end
  end

  # CONFLICT OF INTEREST DECLARATIONS
  # ---------------------------------

  context 'when the disposition incluces conflict of interest declarations' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:with_conflict_of_interest))
    end

    it 'should find the correct conflict of interest declaration count' do
      conflict_declarations = disposition.conflict_of_interest_declarations
      expect(conflict_declarations.size).to eq(1)
    end

    it 'should find the subject of the first delclaration item' do
      conflict_declarations = disposition.conflict_of_interest_declarations
      declaration_subject = conflict_declarations.first[:subject]
      expect(declaration_subject).to eq('Item 2 Report of the Executive Policy Committee Dated July 6, 2016')
    end

    it 'should find the correct declaration member count' do
      conflict_declarations = disposition.conflict_of_interest_declarations
      declaration_members = conflict_declarations.first[:members]
      expect(declaration_members.size).to eq(1)
    end

    it 'should find the name of the first declaration member' do
      conflict_declarations = disposition.conflict_of_interest_declarations
      declaration_members = conflict_declarations.first[:members]
      expect(declaration_members.first).to eq('Councillor Mayes')
    end
  end

  context 'when the disposition does not include conflict of interest declarations' do
    subject(:disposition) do
      Disposition.new(DispositionFixture.fixtures(:without_conflict_of_interest))
    end

    it 'should find the correct conflict of interest declaration count' do
      conflict_declarations = disposition.conflict_of_interest_declarations
      expect(conflict_declarations.size).to eq(0)
    end
  end
end

# rubocop:enable Metrics/LineLength
