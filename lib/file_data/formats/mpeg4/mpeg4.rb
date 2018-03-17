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
      FileData::BoxStream.new(stream).boxes.each do |box|
        return parse_mvhd(stream, box) if box.type == 'moov'
      end
    end

    def self.parse_mvhd(stream, moov_box)
      FileData::BoxSubStream.new(stream, moov_box).boxes.each do |sub_box|
        return parse_mvhd_creation_date(stream) if sub_box.type == 'mvhd'
      end
    end

    def self.parse_mvhd_creation_date(stream)
      version = read_value(1, stream)
      read_value(3, stream) # Flags bytes

      creation_time = read_value(version == 1 ? 8 : 4, stream)
      epoch_delta = 2_082_844_800
      Time.at(creation_time - epoch_delta)
    end
  end
end
