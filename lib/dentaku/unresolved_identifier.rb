module Dentaku
  
  class UnresolvedIdentifier < StandardError
    attr_reader :object
    def initialize(object)
      super("There is no reference for '#{object.raw_value}'")
    end
  end
end