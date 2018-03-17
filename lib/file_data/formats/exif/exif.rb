require_relative 'exif_reader'
require_relative 'exif_jpeg'

module FileData
  # Convenience class for extracting exif data from a file or stream
  class Exif
    class << self
      ['.jpeg', '.jpg'].each { |e| File.info_maps[e] = self }
    end

    # Create methods that forward to ExifReader
    # Each method requires the stream as a parameter to help the user
    # fall into a "pit of success" by only opening and closing
    # the stream once to get data
    ExifReader.public_instance_methods(false).each do |method_name|
      define_singleton_method(method_name) do |input, *other_args|
        delegate_to_exif_reader(input, method_name, other_args)
      end
    end

    def self.delegate_to_exif_reader(input, name, other_args)
      streamify(input) do |stream|
        exif = ExifJpeg.new(stream).exif
        ExifReader.new(exif).send(name, *other_args)
      end
    end

    def self.streamify(input)
      if input.is_a?(String)
        ::File.open(input, 'rb') { |f| yield f }
      else
        yield input
      end
    end

    def creation_date(input)
      FileData::Exif.only_image_tag(input, [34_665, 36_867])
    end
  end
end
