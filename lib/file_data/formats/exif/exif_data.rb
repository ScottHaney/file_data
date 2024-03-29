require 'set'

module FileData
  # Container for Exif tag values
  class ExifData
    SECTIONS = { 0 => :image, 1 => :thumbnail }.freeze
    SECTIONS.each { |section| define_method(section[1]) { @hash[section[0]] } }

    def initialize
      @hash = SECTIONS.each_with_object({}) { |pair, hash| hash[pair[0]] = ExifHash.new }
    end

    def add_tag(index, ifd_id, tag_id, tag_value)
      name_info = ExifTags.get_tag_name(ifd_id, tag_id)
      @hash[index][name_info.name] = tag_value
    end
  end

  # Hash with convenience methods for accessing known Exif tag values by name
  class ExifHash < BasicObject
    all_tags = ExifTags.tag_groups.values.map{|x| x.values}.flatten
    tags_map = all_tags.each_with_object({}) do |tag, hash|
      hash[tag.to_s.split('_').last.upcase] = tag
    end

    define_method(:method_missing) do |method_name, *args, &block|
      known_name = tags_map[method_name.to_s.tr('_', '').upcase]
      
      if known_name.nil?
        @hash.send(method_name, *args, &block)
      else
        @hash[known_name]
      end
    end

    define_method(:respond_to_missing?) do |method_name, include_private|
      known_name = tags_map[method_name.to_s.tr('_', '').upcase]
      
      if known_name.nil?
        @hash.respond_to?(known_name) || super
      else
        true
      end
    end

    def initialize
      @hash = {}
    end

    def [](key)
      @hash[key]
    end

    def []=(key, value)
      @hash[key] = value
    end
  end
end
