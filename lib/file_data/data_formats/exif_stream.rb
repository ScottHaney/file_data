module FileData
  # Wraps a stream with exif specific logic
  class ExifStream
    MOTOROLLA_BYTES = 'MM'.bytes.to_a.freeze
    INTEL_BYTES = 'II'.bytes.to_a.freeze

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

    attr_reader :stream

    def initialize(stream)
      @stream, @section_offset = stream, stream.pos
    end

    def read_header
      @is_big_endian = case @stream.each_byte.take(2)
          when INTEL_BYTES then false
          when MOTOROLLA_BYTES then true
          else raise 'the byte order bytes did not match any expected value'
        end

      raise 'the tiff constant 42 is missing' unless read_value(2) == 42
    end

    def seek_exif(offset)
      @stream.seek(@section_offset + offset)
    end

    def read_tag_value
      type = read_value(2)
      size = read_value(4)

      case type
        when TYPE_RATIONAL, TYPE_SRATIONAL
          read_large_val(type)
        when TYPE_BYTE, TYPE_SHORT, TYPE_LONG, TYPE_SLONG
          read_small_val(type)
        when TYPE_ASCII
          read_text(size)
        when TYPE_UNDEFINED
          read_undefined(size)
      end
    end

    def read_text(size)
      read_raw_val(size).pack('c*').chomp("\x00")
    end

    def read_undefined(size)
      [read_raw_val(size), @is_big_endian]
    end

    def read_raw_val(size)
      seek_to_large_val if size > VALUE_OFFSET_SIZE
      @stream.each_byte.take([size, VALUE_OFFSET_SIZE].max)
    end

    def read_large_val(type)
      seek_to_large_val
      read_rational(type == TYPE_SRATIONAL)
    end

    def read_small_val(type)
      value = read_value(4)
      type == TYPE_SLONG ? to_slong(value) : value
    end

    def seek_to_large_val
      seek_exif(read_value(4))
    end

    def read_rational(is_srational)
      Array.new(2) do
        piece = read_value(4)
        is_srational ? to_slong(piece) : piece
      end.join('/')
    end

    def to_slong(raw_value)
      -(raw_value & HIGH_BIT_MASK) + (raw_value & ~HIGH_BIT_MASK)
    end

    def read_value(num_bytes)
      bytes = @stream.each_byte.take(num_bytes)
      (@is_big_endian ? bytes : bytes.reverse).inject { |total, val| (total << 8) + val }
    end
  end
end