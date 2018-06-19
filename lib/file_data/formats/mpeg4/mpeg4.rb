require_relative 'box_stream'
require_relative '../../core_extensions/binary_extensions'
require 'date'

module FileData
  # Parses and returns metadata from an Mpeg4 file
  class Mpeg4
    extend BinaryExtensions

    class << self
      ['.mp4', '.mpeg4'].each { |e| File.info_maps[e] = self }
    end

    def self.creation_date(stream)
      box = get_box(stream, 'moov', 'mvhd')
      return parse_mvhd_creation_date(stream) unless box.nil?
    end

    def self.parse_mvhd_creation_date(stream)
      version = read_value(1, stream)
      read_value(3, stream) # Flags bytes

      creation_time = read_value(version == 1 ? 8 : 4, stream)
      epoch_delta = 2_082_844_800
      Time.at(creation_time - epoch_delta)
    end

    def self.get_box(stream, *box_path)
      reader = FileData::BoxesReader.for_file(stream)
      box = nil
      box_path.each do |part|
        box = reader.boxes.find { |box| box.type == part }
        return nil if box.nil?
        reader = FileData::BoxesReader.for_box(stream, box)
      end

      return box
    end
  end
end
