require 'file_data/file_types/jpeg'
require 'file_data/data_formats/exif_stream'

module FileData
  class ExifJpeg
    APP1_BYTES = [255, 225].freeze
    EXIF_ID_BYTES = "Exif\0\0".bytes.to_a.freeze

    def initialize(stream)
      @stream = stream
    end

    def get_exif
      Jpeg.new(@stream).each_section
          .select { |marker, _| exif_section?(marker) }
          .first
    end

    def exif_section?(section_tag)
      section_tag == APP1_BYTES && @stream.each_byte.take(EXIF_ID_BYTES.size) == EXIF_ID_BYTES
    end
  end
end