require 'erb'

class ErbBinding
  include ERB::Util

  def initialize(options)
    @template = options[:erb_template]
    @data     = options[:data_to_bind]
  end

  def render
    return ERB.new(@template).result(binding)
  end
end
