require_relative 'exif_reader'
require_relative 'exif_jpeg'
require 'time'

module FileData
  # Convenience class for extracting exif data from a file or stream
  class Exif
    ['.jpeg', '.jpg'].each { |e| FileInfo.info_maps[e] = Exif }

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

    def self.creation_date(input)
      raw_tag = FileData::Exif.only_image_tag(input, [34_665, 36_867])
      Time.strptime(raw_tag, '%Y:%m:%d %H:%M:%S') unless raw_tag.nil?
    end

    def self.origin_date(input)
      creation_date(input)
    end
  end
end
