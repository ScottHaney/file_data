module FileData
  class BoxFactory
    class << self
      attr_reader :map
    end

    @map ||= {}
  end
end
