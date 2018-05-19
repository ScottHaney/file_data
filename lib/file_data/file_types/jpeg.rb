module FileData
  # Represents a Jpeg image stream
  class Jpeg
    SOI_BYTES = [255, 216].freeze
    SECTION_HEADER_SIZE = 4
    INVALID_HEADER_MSG = 'the given file is not a jpeg file since it does not'\
     'begin with the start of image (SOI) bytes.'.freeze

    def initialize(stream)
      @stream = stream
    end

    def each_section
      read_header
      Enumerator.new { |e| yield_sections(e) }.lazy
    end

    def read_header
      soi = read_bytes(SOI_BYTES.size)
      raise INVALID_HEADER_MSG unless soi == SOI_BYTES
    end

    def yield_sections(enumerator)
      loop do
        next_section_pos = yield_section(enumerator)
        break unless section_pos?(next_section_pos)
        @stream.seek(next_section_pos)
      end
    end

    def yield_section(enumerator)
      section_start_pos = @stream.pos + 2
      marker, size = read_section_header
      enumerator.yield marker, size
      section_start_pos + size
    end

    def section_pos?(section_pos)
      # Make sure that there are enough bytes for a section header.
      # This also handles an ending two byte JPEG EOI sequence.
      @stream.size - section_pos >= SECTION_HEADER_SIZE
    end

    def read_section_header
      [read_bytes(2), read_bytes(2).inject { |a, v| (a << 8) + v }]
    end

    def read_bytes(num_bytes)
      @stream.each_byte.take(num_bytes)
    end
  end
end
