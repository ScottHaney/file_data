module FileData
  # Container for Exif tag values
  class ExifData
    SECTIONS = { 0 => :image, 1 => :thumbnail }.freeze
    SECTIONS.each { |section| define_method(section[1]) { @hash[section[0]] } }

    def initialize
      @hash = SECTIONS.each_with_object({}) { |pair, hash| hash[pair[0]] = {} }
    end

    def add_tag(index, ifd_id, tag_id, tag_value)
      name = ExifTags.get_tag_name(ifd_id, tag_id)
      @hash[index][name] = tag_value
    end
  end
end
