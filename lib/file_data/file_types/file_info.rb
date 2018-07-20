module FileData
  # Operations common to all files
  class FileInfo
    class << self
      attr_reader :info_maps
    end

    @info_maps ||= {}

    ['creation_date', 'origin_date'].each do |method_name|
      define_singleton_method(method_name) do |filename|
        File.open(filename, 'rb') do |stream|
          reader = reader_class(filename)
          raise "No metadata parser class found for the file #{filename}" if reader.nil?
  
          reader_class(filename).send(method_name, stream)
        end
      end
    end

    def self.reader_class(filename)
      info_maps[get_reader_key(filename)]
    end

    def self.can_handle?(filename)
      info_maps.key?(get_reader_key(filename))
    end

    def self.get_reader_key(filename)
      File.extname(filename).downcase
    end
  end
end
