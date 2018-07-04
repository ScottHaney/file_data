require_relative 'box_path'
require_relative '../../core_extensions/binary_extensions'
require_relative 'box_parsers/meta_box'
require_relative 'box_parsers/mvhd_box'

module FileData
  # Parses and returns metadata from an Mpeg4 file
  class Mpeg4
    extend BinaryExtensions

    class << self
      ['.mp4', '.mpeg4', '.m4v'].each { |e| FileInfo.info_maps[e] = Mpeg4 }
    end

    def self.origin_date(stream)
      mb = BoxPath.get_root_path(stream, 'moov', 'meta')

      if mb.nil?
        nil
      else
        MetaBoxParser.parse(mb.content_stream).creation_date
      end
    end

    def self.creation_date(stream)
      box = BoxPath.get_root_path(stream, 'moov', 'mvhd')

      if box.nil?
        nil
      else
        MvhdBoxParser.parse(box.content_stream).creation_time
      end
    end
  end
end
