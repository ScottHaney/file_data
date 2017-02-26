module FileData
  # Represents a Jpeg image
  class Jpeg
    SOI_BYTES = [255, 216].freeze
    SECTION_HEADER_SIZE = 4

    def initialize(stream)
      @stream = stream
    end

    def each_section
      read_header
      Enumerator.new { |e| yield_sections(e) }.lazy
    end

    def read_header
      # Read the jpeg SOI bytes
      soi = read_bytes(SOI_BYTES.size)
      raise 'the given file is not a jpeg file since it does not begin with the start of image (SOI) bytes' unless soi == SOI_BYTES
    end

    def yield_sections(e)
      loop do
        next_section_pos = yield_section(e)
        break unless is_section_pos(next_section_pos)
        @stream.seek(next_section_pos)
      end
    end

    def yield_section(e)
      section_start_pos = @stream.pos + 2
      marker, size = read_section_header
      e.yield marker, size
      section_start_pos + size
    end

    def is_section_pos(section_pos)
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
