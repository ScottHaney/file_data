require 'file_data/data_formats/exif_jpeg'
require 'file_data/core_extensions/enumerable_extensions'
require 'file_data/data_formats/exif_tags'
require 'set'
require 'file_data/data_formats/exif_stream'
require 'file_data/data_formats/exif_tag_reader'
require 'file_data/data_formats/exif_data'

module FileData
  # Returns the exif data from a jpeg file
  class Exif
    def initialize(exif_stream)
      @exif_stream = exif_stream
    end

    def self.from_stream(stream)
      Exif.new(ExifJpeg.new(stream).exif)
    end

    def image_data_only
      exif_tags_internal(0).image
    end

    def thumbnail_data_only
      exif_tags_internal(1).thumbnail
    end

    def all_data
      exif_tags_internal(0, 1)
    end

    def only_image_tag(tag_id)
      exif_tag_internal(0, tag_id)
    end

    def only_thumbnail_tag(tag_id)
      exif_tag_internal(1, tag_id)
    end

    def exif_tags_internal(*ifds_to_include)
      tags(*ifds_to_include).each_with_object(ExifData.new) do |tag_info, data|
        data.add_tag(*tag_info, @exif_stream.read_tag_value)
      end
    end

    def exif_tag_internal(ifd_index, tag_to_find)
      @exif_stream.read_tag_value if find_tag(ifd_index, tag_to_find)
    end

    def find_tag(ifd_index, tag_to_find)
      tags(ifd_index).find do |_, ifd_id, tag_num|
        tag_to_find == [ifd_id, tag_num]
      end
    end

    def tags(*ifds_to_include)
      return [] if @exif_stream.nil?

      @exif_stream.read_header
      ExifTagReader.new(@exif_stream, *ifds_to_include).tags
    end
  end
end
