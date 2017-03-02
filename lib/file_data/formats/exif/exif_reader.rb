require_relative 'exif_jpeg'
require 'set'
require_relative 'exif_tag_reader'
require_relative 'exif_data'

module FileData
  # Returns the exif data from a jpeg file
  class ExifReader
    def image_data_only(exif_stream)
      exif_tags_internal(exif_stream, 0).image
    end

    def thumbnail_data_only(exif_stream)
      exif_tags_internal(exif_stream, 1).thumbnail
    end

    def all_data(exif_stream)
      exif_tags_internal(exif_stream, 0, 1)
    end

    def only_image_tag(exif_stream, tag_id)
      exif_tag_internal(exif_stream, 0, tag_id)
    end

    def only_thumbnail_tag(exif_stream, tag_id)
      exif_tag_internal(exif_stream, 1, tag_id)
    end

    def exif_tags_internal(exif_stream, *ifds_to_include)
      tags(exif_stream, *ifds_to_include).each_with_object(ExifData.new) do |tag_info, data|
        data.add_tag(*tag_info, exif_stream.read_tag_value)
      end
    end

    def exif_tag_internal(exif_stream, ifd_index, tag_to_find)
      exif_stream.read_tag_value if find_tag(exif_stream, ifd_index, tag_to_find)
    end

    def find_tag(exif_stream, ifd_index, tag_to_find)
      tags(exif_stream, ifd_index).find do |_, ifd_id, tag_num|
        tag_to_find == [ifd_id, tag_num]
      end
    end

    def tags(exif_stream, *ifds_to_include)
      return [] if exif_stream.nil?

      exif_stream.read_header
      ExifTagReader.new(exif_stream, *ifds_to_include).tags
    end
  end
end
