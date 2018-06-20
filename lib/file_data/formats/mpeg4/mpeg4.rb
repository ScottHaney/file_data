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
      value = stream.each_byte.take(data_box.content_size - 8).map(&:chr).join

      IlstBox.new(index, data_type, locale, value)
    end

    def self.keys_box(stream)
      version = read_value(1, stream)
      flags = read_value(3, stream)

      entry_count = read_value(4, stream)
      
      keys = []
      entry_count.times do |index|
        size = read_value(4, stream)
        namespace = read_ascii(4, stream)
        value = read_ascii(size - 8, stream)
        
        keys << Key.new(index + 1, namespace, value)
      end

      return keys
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
    attr_reader :index, :data_type, :locale, :value_bytes

    def initialize(index, data_type, locale, value_bytes)
      @index = index
      @data_type = data_type
      @locale = locale
      @value_bytes = value_bytes
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
