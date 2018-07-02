require_relative 'keys_box'
require_relative 'ilst_box'
require_relative '../boxes_reader'

module FileData
  # Parser for the 'meta' box
  class MetaBoxParser
    def self.parse(view)
      creation_key = get_creation_key(view)
      return MetaBox.new(nil) if creation_key.nil?

      creation_date_data = get_creation_date(view, creation_key.index)
      return MetaBox.new(nil) if creation_date_data.nil?

      MetaBox.new(Time.parse(creation_date_data.data_box.value_text))
    end

    def self.get_creation_key(view)
      kb = get_path(view, 'keys')
      keys = KeysBoxParser.parse(kb.content_stream)
      keys.find { |key| key.value == 'com.apple.quicktime.creationdate' }
    end

    def self.get_creation_date(view, index)
      ilst_boxes = get_ilst_boxes(view)
      ilst_boxes.find { |x| x.index == index }
    end

    def self.get_ilst_boxes(view)
      view.seek view.start_pos
      box = get_path(view, 'ilst')
      ilst_boxes = []
      ilst_boxes << IlstBoxParser.parse(box.content_stream) until box.content_stream.eof?
      ilst_boxes
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

  MetaBox = Struct.new(:creation_date)
end
