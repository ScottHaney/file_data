module FileData
  # Contains the ability to enumerate through the exif tags in an ifd
  module TagEnumerator
    TAG_RECORD_SIZE = 12

    def tags_enum
      Enumerator.new do |e|
        read_num_tags.times do
          tag_start_pos = stream.pos
          e.yield stream.read_value(2)
          stream.seek(tag_start_pos + TAG_RECORD_SIZE)
        end
      end.lazy
    end

    def read_num_tags
      stream.read_value(2)
    end

    def tags_size(num_tags)
      num_tags * TAG_RECORD_SIZE
    end
  end

  # Represents the tags present in any ifd (ordinal or extra)
  class Ifd
    include TagEnumerator

    attr_accessor :stream

    def initialize(exif_stream)
      @stream = exif_stream
    end

    def tags
      tags_enum
    end
  end
end
