require_relative 'boxes_reader'
require_relative '../../core_extensions/binary_extensions'
require 'date'
require_relative 'box_parsers/ilst_box'
require_relative 'box_parsers/keys_box'
require_relative 'box_parsers/mvhd_box'

module FileData
  # Parses and returns metadata from an Mpeg4 file
  class Mpeg4
    extend BinaryExtensions

    class << self
      ['.mp4', '.mpeg4', '.m4v'].each { |e| FileInfo.info_maps[e] = Mpeg4 }
    end

    def self.origin_date(stream)
      mb = get_root_path(stream, 'moov', 'meta')

      if mb.nil?
        nil
      else
        MetaBoxParser.parse(mb.content_stream).creation_date
      end
    end

    def self.creation_date(stream)
      box = get_root_path(stream, 'moov', 'mvhd')

      if box.nil?
        nil
      else
        MvhdBoxParser.parse(box.content_stream).creation_time
      end
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
