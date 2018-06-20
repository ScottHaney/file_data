require_relative '../../core_extensions/binary_extensions'

module FileData
  # Mpeg4 box
  class Box
    include BinaryExtensions

    attr_reader :type, :content_pos, :content_size, :size

    def read(stream)
      marker = stream.pos
      first_field = read_value(4, stream)
      @type = read_ascii(4, stream)

      @size =
        if first_field == 1
          read_value(8, stream)
        else
          first_field
        end

      @content_pos = stream.pos
      @content_size = @size - (@content_pos - marker)
    end
  end
end
