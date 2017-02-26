require 'file_data/file_types/jpeg'
require 'file_data/data_formats/exif_stream'

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

    def seek_exif
      Jpeg.new(@stream).each_section
          .select { |marker, _| exif_section?(marker) }
          .first
    end

    def exif_section?(marker)
      marker == APP1_BYTES && @stream.each_byte.take(EXIF_ID.size) == EXIF_ID
    end
  end
end
