require_relative 'box_path'
require_relative '../../core_extensions/binary_extensions'
require_relative 'box_parsers/meta_box'
require_relative 'box_parsers/mvhd_box'

module FileData
  Mpeg4ValueInfo = Struct.new(:name, :parser_class, :method_name, :box_path)

  # Parses and returns metadata from an Mpeg4 file
  class Mpeg4
    extend BinaryExtensions

    class << self
      ['.mp4', '.mpeg4', '.m4v'].each { |e| FileInfo.info_maps[e] = Mpeg4 }

      values = [ Mpeg4ValueInfo.new('origin_date', MetaBoxParser, 'creation_date', ['moov', 'meta']),
                Mpeg4ValueInfo.new('creation_date', MvhdBoxParser, 'creation_time', ['moov', 'mvhd'])]

      values.each do |v|
        define_method(v.name) do |stream|
          get_value(stream, v.parser_class, v.method_name, *v.box_path)
        end
      end
    end
    
    def self.get_value(stream, parser, method, *box_path)
      box = BoxPath.get_root_path(stream, *box_path)

      if box.nil?
        nil
      else
        parser.parse(box.content_stream).send(method)
      end
    end
  end
end
