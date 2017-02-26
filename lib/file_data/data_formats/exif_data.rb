module FileData
  # Contains structured representation of exif tags and values
  class ExifData
    NAMES = { 0 => :image, 1 => :thumbnail }.freeze

    def initialize
      @hash = { 0 => {}, 1 => {} }
      @hash.keys.each do |k|
        self.class.send(:define_method, NAMES[k]) { @hash[k] }
      end
    end

    def add_tag(index, ifd_id, tag_id, tag_value)
      name = ExifTags.get_tag_name(ifd_id, tag_id)
      @hash[index][name] = tag_value
    end
  end
end
