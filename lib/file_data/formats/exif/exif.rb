require_relative 'exif_reader'
require_relative 'exif_jpeg'

module FileData
  # Convenience class for extracting exif data from a file or stream
  class Exif
    def method_missing(name, *args)
      return super if args.length.zero?
      process(args[0], name, args.drop(1))
    end

    def process(input, name, other_args)
      streamify(input) do |stream|
        exif = ExifJpeg.new(stream).exif
        ExifReader.new.send(name, exif, *other_args)
      end
    end

    def streamify(input)
      if input.is_a?(String)
        File.open(input, 'rb') { |f| yield f }
      else
        yield input
      end
    end
  end
end
