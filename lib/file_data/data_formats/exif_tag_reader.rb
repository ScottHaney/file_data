require 'file_data/data_formats/exif_stream'
require 'file_data/data_formats/ordinal_ifd'

module FileData
  class ExifTagReader

    def initialize(exif_stream, *ifds_to_include)
      @exif_stream = exif_stream
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

      if @ifds_to_include.include?(ifd.index)
        ifd.all_tags.each { |t| e.yield t }
      else
        # Avoid skipping the last ifd as this is needless work
        ifd.skip unless ifd.index == 1
      end
    end

    def next_ifd(index)
      # An ifd offset of zero indicates that there is no next ifd
      ifd_offset = @exif_stream.read_value(4)
      OrdinalIfd.new(@exif_stream, ifd_offset, index) unless ifd_offset == 0
    end
  end
end