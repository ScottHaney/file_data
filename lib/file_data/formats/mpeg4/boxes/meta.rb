require_relative '../box_factory'

module FileData
  class Meta
    class << self
      BoxFactory.map['meta'] = self
    end
  end
end
