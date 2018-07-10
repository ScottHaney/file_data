require_relative '../../helpers/stream_view'

module FileData
  # Mpeg4 box
  class Box
    attr_reader :type, :content_stream, :end_pos

    def initialize(type, content_stream)
      @type = type
      @content_stream = content_stream
      @end_pos = @content_stream.end_pos
    end

    def self.parse(view)
      type, pos, size = parse_header(view)
      new(type, Helpers::SubStreamView.new(view.stream, pos, size))
    end

    def self.parse_header(view)
      start_pos = view.pos
      first_field = view.read_value(4)
      type = view.read_ascii(4)

      total_size =
        if first_field == 1
          view.read_value(8)
        else
          first_field
        end

      content_pos = view.pos
      header_size = content_pos - start_pos
      content_size = total_size - header_size

      [type, content_pos, content_size]
    end
  end
end
