require_relative 'ifd'
require_relative 'exif_tags'

module FileData
  # Represents either the zeroth or first ifd
  class OrdinalIfd
    attr_reader :stream, :index

    include TagEnumerator

    def initialize(exif_stream, index)
      @stream = exif_stream
      @index = index
    end

    def tags
      Enumerator.new do |e|
        tags_enum.each { |tag_id| process_tag(e, tag_id) }
      end
    end

    def process_tag(enumerator, tag_id)
      if pointer_tag?(tag_id)
        process_extra_ifd(enumerator, tag_id)
      else
        yield_tag(enumerator, :Tiff, tag_id)
      end
    end

    def pointer_tag?(tag_id)
      ExifTags.tag_groups.key?(tag_id)
    end

    def process_extra_ifd(enumerator, tag_id)
      seek_ifd(stream.read_tag_value)
      tags_enum.each { |t| yield_tag(enumerator, tag_id, t) }
    end

    def yield_tag(enumerator, ifd_id, tag_id)
      enumerator.yield [index, ifd_id, tag_id]
    end

    def seek_ifd(pointer_value)
      stream.seek_exif(pointer_value)
    end

    def skip
      stream.seek(tags_size(read_num_tags), IO::SEEK_CUR)
    end    
  end
end
