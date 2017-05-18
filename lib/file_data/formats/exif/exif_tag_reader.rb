require_relative 'exif_stream'
require_relative 'ordinal_ifd'

module FileData
  # Enumerates the tags in an ExifStream
  class ExifTagReader
    NO_NEXT_IFD = 0

    attr_accessor :stream, :ifds_to_include

    def initialize(exif_stream, *ifds_to_include)
      @stream = exif_stream
      @ifds_to_include = ifds_to_include
    end

    def tags
      Enumerator.new do |e|
        2.times do |index|
          break if (ifd = next_ifd(index)).nil?
          process_ifd(ifd, e)
        end
      end
    end

    def process_ifd(ifd, e)
      # Yield the tags or just skip ahead

      if ifds_to_include.include?(ifd.index)
        ifd.tags.each { |t| e.yield t }
      else
        # Avoid skipping the last ifd as this is needless work
        ifd.skip unless ifd.index == 1
      end
    end

    def next_ifd(index)
      ifd_offset = stream.read_value(4)
      ifd_from_offset(ifd_offset, index) unless ifd_offset == NO_NEXT_IFD
    end

    def ifd_from_offset(ifd_offset, index)
      stream.seek_exif(ifd_offset)
      OrdinalIfd.new(stream, index)
    end
  end
end
