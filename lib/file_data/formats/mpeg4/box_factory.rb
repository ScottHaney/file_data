module FileData
  # Factory mapping box type to a class that can parse it
  class BoxFactory
    class << self
      attr_reader :map
    end

    @map ||= {}
  end
end
