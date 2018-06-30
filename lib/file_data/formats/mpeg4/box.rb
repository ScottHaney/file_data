require_relative '../../core_extensions/binary_extensions'
require_relative '../../helpers/stream_view'

module FileData
  # Mpeg4 box
  class Box
    extend BinaryExtensions

    attr_reader :type, :content_stream, :end_pos

    def initialize(type, content_stream)
      @type = type
      @content_stream = content_stream
      @end_pos = @content_stream.end_pos
    end

    def self.parse(stream)
      type, pos, size = parse_header(stream)
      new(type, Helpers::SubStreamView.new(stream, pos, size))
    end

    def self.parse_header(stream)
      start_pos = stream.pos
      first_field = read_value(4, stream)
      type = read_ascii(4, stream)

      total_size =
        if first_field == 1
          read_value(8, stream)
        else
          first_field
        end

      content_pos = stream.pos
      header_size = content_pos - start_pos
      content_size = total_size - header_size
      
      return type, content_pos, content_size
    end
  end
end
