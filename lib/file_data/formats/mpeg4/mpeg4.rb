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

      data_box = FileData::BoxesReader.for_position(stream, stream.pos, size - 8).boxes.find { |box| box.type == 'data' }
      
      data_type = read_value(4, stream)
      locale = read_value(4, stream)
      value = read_ascii(data_box.content_size - 8, stream)

      IlstBox.new(index, data_type, locale, value)
    end

    def self.keys_box(stream)
      version = read_value(1, stream)
      flags = read_value(3, stream)

      entry_count = read_value(4, stream)
      
      keys = entry_count.times.map do |index|
        size = read_value(4, stream)
        namespace = read_ascii(4, stream)
        value = read_ascii(size - 8, stream)
        
        Key.new(index + 1, namespace, value)
      end
    end

    def self.origin_date(stream)
      keys_box = FileData::Mpeg4.get_box(stream, 'moov', 'meta', 'keys')
      keys = FileData::Mpeg4.keys_box(stream)

      creation_key = keys.find { |key| key.value == 'com.apple.quicktime.creationdate' }

      box = FileData::Mpeg4.get_box(stream, 'moov', 'meta', 'ilst')
        
      ilst_boxes = []
      while stream.pos < box.content_pos + box.content_size
        ilst_boxes << FileData::Mpeg4.ilst_box(stream)
      end

      creation_date_data = ilst_boxes.find { |box| box.index == creation_key.index }
      DateTime.strptime(creation_date_data.value_text)
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

  class IlstBox
    attr_reader :index, :data_type, :locale, :value_text

    def initialize(index, data_type, locale, value_text)
      @index = index
      @data_type = data_type
      @locale = locale
      @value_text = value_text
    end
  end

  class Key
    attr_reader :index, :namespace, :value

    def initialize(index, namespace, value)
      @index = index
      @namespace = namespace
      @value = value
    end
  end
end
