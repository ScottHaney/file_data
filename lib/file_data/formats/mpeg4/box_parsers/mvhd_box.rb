module FileData
  # Parser for the 'mvhd' box
  class MvhdBoxParser
    def self.parse(view)
      MvhdBox.new(parse_mvhd_creation_date(view))
    end

    def self.parse_mvhd_creation_date(view)
      version = view.read_value(1)
      view.read_value(3) # Flags bytes

      creation_time = view.read_value(version == 1 ? 8 : 4)
      epoch_delta = 2_082_844_800
      Time.at(creation_time - epoch_delta)
    end
  end

  MvhdBox = Struct.new(:creation_time)
end
