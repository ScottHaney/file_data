module FileData
  class Ifd
    TAG_RECORD_SIZE = 12

    def initialize(exif_stream, offset)
      @exif_stream = exif_stream
      @exif_stream.seek_exif(offset)
      @num_tags = @exif_stream.read_value(2)
    end

    def tags
      Enumerator.new do |e|
        @num_tags.times do
          tag_start_pos = @exif_stream.stream.pos
          e.yield @exif_stream.read_value(2)
          @exif_stream.stream.seek(tag_start_pos + TAG_RECORD_SIZE)
        end
      end.lazy
    end
  end
end