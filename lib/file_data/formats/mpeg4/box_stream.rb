require_relative 'box'

module FileData
  class BoxStream
    def initialize(stream)
      @stream = stream
    end

    def boxes
      Enumerator.new do |e|
        cur_pos = 0
        until @stream.eof?
          @stream.seek cur_pos

          box = FileData::Box.new
          box.read(@stream)

          e.yield box
          cur_pos += box.size
        end
      end.lazy
    end
  end

  class BoxSubStream
    def initialize(stream, parent_box)
      @stream = stream
      @parent_box = parent_box
    end

    def boxes
      initial_pos = @stream.pos
      Enumerator.new do |e|
        cur_pos = @stream.pos
        until cur_pos >= initial_pos + @parent_box.size
          @stream.seek cur_pos

          box = FileData::Box.new
          box.read(@stream)

          e.yield box
          cur_pos += box.size
        end
      end.lazy
    end
  end
end
