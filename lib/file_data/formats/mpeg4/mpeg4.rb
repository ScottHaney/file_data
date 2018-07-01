require_relative 'boxes_reader'
require_relative '../../core_extensions/binary_extensions'
require 'date'
require_relative 'box_parsers/ilst_box'
require_relative 'box_parsers/keys_box'

module FileData
  # Parses and returns metadata from an Mpeg4 file
  class Mpeg4
    extend BinaryExtensions

    class << self
      ['.mp4', '.mpeg4'].each { |e| File.info_maps[e] = self }
    end

    def self.origin_date(stream)
      mb = get_root_path(stream, 'moov', 'meta')
      meta_box = MetaBoxParser.parse(mb.content_stream)
      meta_box.creation_date
    end

    def self.creation_date(stream)
      box = get_root_path(stream, 'moov', 'mvhd')
      return parse_mvhd_creation_date(stream) unless box.nil?
    end

    def self.parse_mvhd_creation_date(stream)
      version = read_value(1, stream)
      read_value(3, stream) # Flags bytes

      creation_time = read_value(version == 1 ? 8 : 4, stream)
      epoch_delta = 2_082_844_800
      Time.at(creation_time - epoch_delta)
    end

    def self.get_root_path(stream, *box_path)
      get_path(Helpers::StreamView.new(stream), *box_path)
    end

    def self.get_box_path(box, *box_path)
      get_path(box.content_stream, *box_path)
    end

    def self.get_path(stream_view, *box_path)
      match = BoxesReader.read(stream_view).find { |x| x.type == box_path[0] }
      
      if match.nil?
        nil
      elsif box_path.length == 1
        match
      else
        get_path(match.content_stream, *box_path[1..-1])
      end
    end
  end
end
