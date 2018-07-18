require_relative 'box_path'
require_relative 'box_parsers/meta_box'
require_relative 'box_parsers/mvhd_box'

module FileData
  # Parses and returns metadata from an Mpeg4 file
  class Mpeg4
    class << self
      ['.mp4', '.mpeg4', '.m4v', '.mov'].each { |e| FileInfo.info_maps[e] = Mpeg4 }

      values = [['origin_date', MetaBoxParser,
                 'creation_date', 'moov', 'meta'],
                ['creation_date', MvhdBoxParser,
                 'creation_time', 'moov', 'mvhd']]

      values.each do |v|
        define_method(v[0]) do |stream|
          get_value(*v.drop(1).unshift(stream))
        end
      end
    end

    def self.get_value(stream, parser, method, *box_path)
      box = BoxPath.get_root_path(stream, *box_path)
      parser.parse(box.content_stream).send(method) unless box.nil?
    end
  end

  Mpeg4ValueInfo = Struct.new(:name, :parser_class, :method_name, :box_path)
end
