require_relative 'box'

module FileData
  # Top level stream of Mpeg4 boxes
  class BoxStream
    def initialize(stream)
      @stream = stream
      @initial_pos = @stream.pos
    end

    def should_stop(_pos)
      @stream.eof?
    end

    def boxes
      Enumerator.new do |e|
        cur_pos = @initial_pos
        until should_stop(@stream.pos)
          @stream.seek cur_pos

          box = FileData::Box.new
          box.read(@stream)

          e.yield box
          cur_pos += box.size
        end
      end.lazy
    end
  end

  # Stream of child boxes for a parent box
  class BoxSubStream < BoxStream
    def initialize(stream, parent_box)
      super(stream)
      @parent_box = parent_box
    end

    def should_stop(pos)
      pos >= @initial_pos + @parent_box.size
    end
  end
end
