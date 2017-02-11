module FileData
  # Represents a Jpeg image
  class Jpeg
    SOI_BYTES = [255, 216].freeze
    SECTION_HEADER_SIZE = 4

    def self.read_header(stream)
      # Read the jpeg SOI bytes
      soi = stream.each_byte.take(SOI_BYTES.size)
      raise 'the given file is not a jpeg file since it does not begin with the start of image (SOI) bytes' unless soi == SOI_BYTES
    end

    def self.each_section(stream)
      read_header(stream)
      Enumerator.new do |e|
        loop do
          section_start_pos = stream.pos + 2
          marker, size = read_section_header(stream)
          e.yield marker, size

          # There may be a two byte EOI (end of image) sequence after
          # all of the sections. Just ignore any trailing bytes that
          # aren't enough to contain a section header
          next_section_pos = section_start_pos + size
          break unless next_section_pos + (SECTION_HEADER_SIZE - 1) < stream.size
          stream.seek(next_section_pos)
        end
      end.lazy
    end

    def self.read_section_header(stream)
      [stream.each_byte.take(2), stream.each_byte.take(2).inject { |a, v| (a << 8) + v }]
    end
  end
end
