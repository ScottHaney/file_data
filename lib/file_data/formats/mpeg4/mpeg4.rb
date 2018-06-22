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

    def self.ilst_box(stream)
      size = read_value(4, stream)
      index = read_value(4, stream)
      data_box = get_ilst_data_box(stream, size)

      data_type = read_value(4, stream)
      locale = read_value(4, stream)
      value = read_ascii(data_box.content_size - 8, stream)

      IlstBox.new(index, data_type, locale, value)
    end

    def self.get_ilst_data_box(stream, size)
      BoxesReader.for_position(stream, stream.pos, size - 8)
                 .boxes.find { |box| box.type == 'data' }
    end

    def self.keys_box(stream)
      read_value(1, stream) # version field
      read_value(3, stream) # flags field

      entry_count = read_value(4, stream)

      Array.new(entry_count) do |index|
        size = read_value(4, stream)
        namespace = read_ascii(4, stream)
        value = read_ascii(size - 8, stream)

        Key.new(index + 1, namespace, value)
      end
    end

    def self.origin_date(stream)
      meta_box = get_root_path(stream, 'moov', 'meta')

      get_box_path(stream, meta_box, 'keys')
      keys = keys_box(stream)

      creation_key = keys.find { |key| key.value == 'com.apple.quicktime.creationdate' }

      ilst_boxes = get_ilst_boxes(stream, meta_box)

      creation_date_data = ilst_boxes.find { |x| x.index == creation_key.index }
      Time.parse(creation_date_data.value_text)
    end

    def self.get_ilst_boxes(stream, meta_box)
      box = get_box_path(stream, meta_box, 'ilst')
      ilst_boxes = []
      ilst_boxes << ilst_box(stream) while stream.pos < box.content_pos + box.content_size
      ilst_boxes
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
      reader = FileData::BoxesReader.for_file(stream)
      get_path(stream, reader, *box_path)
    end

    def self.get_box_path(stream, box, *box_path)
      reader = FileData::BoxesReader.for_box(stream, box)
      get_path(stream, reader, *box_path)
    end

    def self.get_path(stream, reader, *box_path)
      match = reader.boxes.find { |x| x.type == box_path[0] }

      if match.nil?
        nil
      elsif box_path.length == 1
        match
      else
        get_path(stream, FileData::BoxesReader.for_box(stream, match), *box_path[1..-1])
      end
    end
  end

  IlstBox = Struct.new(:index, :data_type, :locale, :value_text)
  Key = Struct.new(:index, :namespace, :value)
end
