require_relative '../helpers/sized_field'
require_relative '../helpers/stream_view'

module FileData
  # Represents a Jpeg image stream
  class Jpeg
    SOI_BYTES = [255, 216].freeze
    EOI_BYTES = [255, 217].freeze
    SECTION_HEADER_SIZE = 4
    INVALID_HEADER_MSG = 'the given file is not a jpeg file since it does not'\
     'begin with the start of image (SOI) bytes.'.freeze

    def self.each_section(stream)
      view = Helpers::StreamView.new(stream)
      read_header(view)
      Enumerator.new { |e| yield_sections(view, e) }.lazy
    end

    def self.read_header(stream)
      soi = stream.each_byte.take(SOI_BYTES.size)
      raise INVALID_HEADER_MSG unless soi == SOI_BYTES
    end

    def self.yield_sections(stream, enumerator)
      until stream.eof?
        marker = stream.each_byte.take(2)
        break if marker == EOI_BYTES

        section = current_section(stream, marker)
        enumerator.yield section
        stream.seek(section.content_stream.end_pos + 1)
      end
    end

    # def self.section_pos?(stream)
    #   # Make sure that there are enough bytes for a section header.
    #   # This also handles an ending two byte JPEG EOI sequence.
    #   stream.size >= SECTION_HEADER_SIZE
    # end

    def self.current_section(stream, marker)
      content_stream = Helpers::SizedField.create_view(stream, 2)
      JpegSection.new(marker, content_stream)
    end
  end

  JpegSection = Struct.new(:marker, :content_stream)
end
