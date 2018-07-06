module FileData
  # Represents a Jpeg image stream
  class Jpeg
    SOI_BYTES = [255, 216].freeze
    SECTION_HEADER_SIZE = 4
    INVALID_HEADER_MSG = 'the given file is not a jpeg file since it does not'\
     'begin with the start of image (SOI) bytes.'.freeze

    def self.each_section(stream)
      read_header(stream)
      Enumerator.new { |e| yield_sections(stream, e) }.lazy
    end

    private

    def self.read_header(stream)
      soi = stream.each_byte.take(SOI_BYTES.size)
      raise INVALID_HEADER_MSG unless soi == SOI_BYTES
    end

    def self.yield_sections(stream, enumerator)
      loop do
        next_section_pos = yield_section(stream, enumerator)
        break unless section_pos?(stream, next_section_pos)
        stream.seek(next_section_pos)
      end
    end

    def self.yield_section(stream, enumerator)
      section_start_pos = stream.pos + 2
      marker, size = read_section_header(stream)
      enumerator.yield marker, size
      section_start_pos + size
    end

    def self.section_pos?(stream, section_pos)
      # Make sure that there are enough bytes for a section header.
      # This also handles an ending two byte JPEG EOI sequence.
      stream.size - section_pos >= SECTION_HEADER_SIZE
    end

    def self.read_section_header(stream)
      [stream.each_byte.take(2),
       stream.each_byte.take(2).inject { |a, v| (a << 8) + v }]
    end
  end
end
