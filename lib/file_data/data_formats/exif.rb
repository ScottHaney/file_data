require 'file_data/file_types/jpeg'
require 'file_data/core_extensions/enumerable_extensions'
require 'file_data/data_formats/exif_tags'

# Refinements to include only for this file
module Refinements
  refine Enumerator do
    include EnumerableExtensions
  end
end

using Refinements

module FileData
  # Returns the exif data from a jpeg file
  class Exif
    APP1_BYTES = [255, 225].freeze
    EXIF_ID_BYTES = "Exif\0\0".bytes.to_a.freeze
    MOTOROLLA_BYTES = 'MM'.bytes.to_a.freeze
    INTEL_BYTES = 'II'.bytes.to_a.freeze

    EXIF_PHOTO_DATETIMEORIGINAL = 36_867
    EXIF_IFD_POINTER = 34_665

    TYPE_BYTE = 1
    TYPE_ASCII = 2
    TYPE_SHORT = 3
    TYPE_LONG = 4
    TYPE_RATIONAL = 5
    TYPE_UNDEFINED = 7
    TYPE_SLONG = 9
    TYPE_SRATIONAL = 10

    HIGH_BIT_MASK = 2**31

    VALUE_OFFSET_SIZE = 4
    TAG_RECORD_SIZE = 12

    # The 'input' argument is either an opened binary stream or a file path
    def read_tags(input, *tags)
      if input.is_a?(String)
        File.open(input, 'rb') { |stream| read_stream_tags(stream, *tags) }
      else
        read_stream_tags(input, *tags)
      end
    end

    def read_stream_tags(binary_stream, *tags)
      each_tag(binary_stream)
        .select { |tag, _value| tags.empty? || tags.include?(tag) }
        .each_with_object({}) do |tag_info, hash|
          add_tag_to_hash(tag_info[0], tag_info[1], hash)
          return hash if hash.size == tags.size
        end
    end

    def add_tag_to_hash(tag, value, hash)
      tag_name = ExifTags::EXIF[tag]
      hash[tag_name.nil? ? tag.to_s.to_sym : tag_name] = value
    end

    def each_tag(stream)
      Jpeg.each_section(stream)
          .select { |marker, _size| exif_section?(stream, marker) }
          .map { process_exif_section(stream) }
          .condense
    end

    def exif_section?(stream, section_tag)
      section_tag == APP1_BYTES && stream.each_byte.take(EXIF_ID_BYTES.size) == EXIF_ID_BYTES
    end

    def process_exif_section(stream)
      section_offset = stream.pos
      is_little_endian = read_header(stream)

      Enumerator.new do |e|
        main_rel_offset = read_value(stream, 4, is_little_endian)
        extra_rel_offsets = process_ifd_block_chain(stream, e, section_offset, main_rel_offset, is_little_endian)

        extra_rel_offsets.each do |extra_rel_offset|
          process_ifd_block_chain(stream, e, section_offset, extra_rel_offset, is_little_endian)
        end
      end.lazy
    end

    def process_ifd_block_chain(stream, enumerator, section_offset, rel_offset, is_little_endian)
      current_rel_offset = rel_offset
      extra_rel_offsets = []

      while current_rel_offset != 0
        stream.seek(section_offset + current_rel_offset)

        tags_in_block(stream, is_little_endian).each do |tag|
          if tag == EXIF_IFD_POINTER
            extra_rel_offsets << get_special_ifd_offset(stream, is_little_endian)
          else
            enumerator.yield [tag, read_tag_value(stream, section_offset, is_little_endian)]
          end
        end

        current_rel_offset = read_value(stream, 4, is_little_endian)
      end

      extra_rel_offsets
    end

    def get_special_ifd_offset(stream, is_little_endian)
      stream.seek(6, IO::SEEK_CUR)
      read_value(stream, 4, is_little_endian)
    end

    def read_header(stream)
      is_little_endian =
        case stream.each_byte.take(2)
        when INTEL_BYTES
          true
        when MOTOROLLA_BYTES
          false
        else
          raise 'the byte order bytes did not match any expected value'
        end

      forty_two = read_value(stream, 2, is_little_endian)
      raise 'the tiff constant 42 is missing' unless forty_two == 42

      is_little_endian
    end

    def tags_in_block(stream, is_little_endian)
      Enumerator.new do |e|
        num_tags = read_value(stream, 2, is_little_endian)
        num_tags.times do
          tag_start_pos = stream.pos
          e.yield read_value(stream, 2, is_little_endian)
          stream.seek(tag_start_pos + TAG_RECORD_SIZE)
        end
      end.lazy
    end

    def read_tag_value(stream, section_offset, is_little_endian)
      type = read_value(stream, 2, is_little_endian)
      size = read_value(stream, 4, is_little_endian)

      case type
      when TYPE_RATIONAL, TYPE_SRATIONAL
        read_large_val(stream, type, section_offset, is_little_endian)
      when TYPE_BYTE, TYPE_SHORT, TYPE_LONG, TYPE_SLONG
        read_small_val(stream, type, is_little_endian)
      when TYPE_ASCII
        read_text(stream, section_offset, size, is_little_endian)
      when TYPE_UNDEFINED
        read_undefined(stream, section_offset, size, is_little_endian)
      end
    end

    def read_text(stream, section_offset, size, is_little_endian)
      read_raw_val(stream, section_offset, size, is_little_endian).pack('c*').chomp("\x00")
    end

    def read_undefined(stream, section_offset, size, is_little_endian)
      [read_raw_val(stream, section_offset, size, is_little_endian), is_little_endian]
    end

    def read_raw_val(stream, section_offset, size, is_little_endian)
      seek_to_large_val(stream, section_offset, is_little_endian) if size > VALUE_OFFSET_SIZE
      stream.each_byte.take([size, VALUE_OFFSET_SIZE].max)
    end

    def read_large_val(stream, type, section_offset, is_little_endian)
      seek_to_large_val(stream, section_offset, is_little_endian)
      read_rational(stream, type == TYPE_SRATIONAL, is_little_endian)
    end

    def read_small_val(stream, type, is_little_endian)
      value = read_value(stream, 4, is_little_endian)
      type == TYPE_SLONG ? to_slong(value) : value
    end

    def seek_to_large_val(stream, section_offset, is_little_endian)
      rel_offset = read_value(stream, 4, is_little_endian)
      stream.seek(section_offset + rel_offset)
    end

    def read_rational(stream, is_srational, is_little_endian)
      Array.new(2) do
        piece = read_value(stream, 4, is_little_endian)
        is_srational ? to_slong(piece) : piece
      end.join('/')
    end

    def to_slong(raw_value)
      -(raw_value & HIGH_BIT_MASK) + (raw_value & ~HIGH_BIT_MASK)
    end

    def read_value(stream, num_bytes, is_little_endian)
      bytes = stream.each_byte.take(num_bytes)
      (is_little_endian ? bytes.reverse : bytes).inject { |total, val| (total << 8) + val }
    end
  end
end
