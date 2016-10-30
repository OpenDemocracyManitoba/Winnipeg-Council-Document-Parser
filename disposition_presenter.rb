require 'forwardable'
require 'date'

class DispositionPresenter
  extend Forwardable
  def_delegator :@disposition_hash, :[]

  def initialize(disposition_hash)
    @disposition_hash = disposition_hash
  end

  def humanized_meeting_date
    DateTime.parse(self['meeting_date']).strftime('%B %d, %Y') 
  end
end
