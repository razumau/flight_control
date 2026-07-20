module FlightControl::IdentifiedByName
  extend ActiveSupport::Concern

  included do
    attr_reader :name
    alias_method :to_s, :name
  end

  def initialize(name:)
    @name = name.to_s
  end

  def id
    name.parameterize
  end

  alias_method :to_param, :id
end
