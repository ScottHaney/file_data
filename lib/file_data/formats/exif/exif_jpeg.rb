require 'file_data/file_types/jpeg'
require_relative 'exif_stream'

module FileData
  # Retrieves an ExifStream from a jpeg stream
  class ExifJpeg
    APP1_BYTES = [255, 225].freeze
    EXIF_ID = "Exif\0\0".bytes.to_a.freeze

    def initialize(stream)
      @stream = stream
    end

    def exif
      ExifStream.new(@stream) if seek_exif
    end

    private

    def seek_exif
      Jpeg.each_section(@stream)
          .select { |section| exif_section?(section) }
          .first
    end

    def exif_section?(section)
      section.marker == APP1_BYTES && read_exif_id(section)
    end

    def read_exif_id(section)
      section.content_stream.each_byte.take(EXIF_ID.size) == EXIF_ID
    end
  end
end
