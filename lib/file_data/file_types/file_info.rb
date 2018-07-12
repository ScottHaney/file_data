module FileData
  # Operations common to all files
  class FileInfo
    class << self
      attr_reader :info_maps
    end

    @info_maps ||= {}

    def self.creation_date(filename)
      File.open(filename, 'rb') do |stream|
        reader_class(filename).creation_date(stream)
      end
    end

    def self.origin_date(filename)
      File.open(filename, 'rb') do |stream|
        reader_class(filename).origin_date(stream)
      end
    end

    def self.reader_class(filename)
      info_maps[File.extname(filename).downcase]
    end
  end
end
