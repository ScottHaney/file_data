require 'file_data/data_formats/ifd'
require 'file_data/data_formats/exif_tags'

module FileData
  class OrdinalIfd < Ifd
    attr_reader :index

    def initialize(exif_stream, offset, index)
      super(exif_stream, offset)
      @index = index
    end

    def all_tags
      Enumerator.new do |e|
        tags.each do |tag_id|
          if ExifTags.tag_groups.key?(tag_id)
            yield_extra_ifd_tags(e, tag_id)
          else
            yield_tag(e, :Tiff, tag_id)
          end
        end
      end
    end

    def yield_extra_ifd_tags(e, tag_id)
      offset = @exif_stream.read_tag_value
      Ifd.new(@exif_stream, offset).tags.each { |t| yield_tag(e, tag_id, t) }
    end

    def yield_tag(e, ifd_id, tag_id)
      e.yield [@index, ifd_id, tag_id]
    end

    def skip
      @exif_stream.seek(@num_tags * Ifd::TAG_RECORD_SIZE, IO::SEEK_CUR)
    end
  end
end
