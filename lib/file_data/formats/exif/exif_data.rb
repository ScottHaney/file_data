module FileData
  # Container for Exif tag values
  class ExifData
    NAMES = { 0 => :image, 1 => :thumbnail }.freeze

    def initialize
      @hash = NAMES.each_with_object({}) do |pair, hash|
        hash[pair[0]] = {}
        self.class.send(:define_method, pair[1]) { @hash[pair[0]] }
      end
    end

    def add_tag(index, ifd_id, tag_id, tag_value)
      name = ExifTags.get_tag_name(ifd_id, tag_id)
      @hash[index][name] = tag_value
    end
  end
end
