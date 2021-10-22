module FileData
  # Container for Exif tag values
  class ExifData
    SECTIONS = { 0 => :image, 1 => :thumbnail }.freeze
    SECTIONS.each { |section| define_method(section[1]) { @hash[section[0]] } }

    def initialize
      @hash = SECTIONS.each_with_object({}) { |pair, hash| hash[pair[0]] = {} }

      #Add some convenience methods to the image data
      image_hash = @hash[0]
      class << image_hash
        def width
          self[:Image_Structure_Width]
        end

        def height
          self[:Image_Structure_Length]
        end
      end
    end

    def add_tag(index, ifd_id, tag_id, tag_value)
      name = ExifTags.get_tag_name(ifd_id, tag_id)
      @hash[index][name] = tag_value
    end
  end
end
