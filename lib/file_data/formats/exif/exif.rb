require_relative 'exif_reader'
require_relative 'exif_jpeg'

module FileData
  # Convenience class for extracting exif data from a file or stream
  class Exif
    # Create methods that forward to ExifReader
    ExifReader.public_instance_methods.each do |method_name|
      define_method(method_name) do |input, *other_args|
        delegate_to_exif_reader(input, method_name, other_args)
      end
    end

    private

    def delegate_to_exif_reader(input, name, other_args)
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
