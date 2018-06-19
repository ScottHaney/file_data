require_relative 'box'

module FileData
  class BoxesReader
    def initialize(stream, start, should_stop)
      @stream = stream
      @start = start
      @should_stop = should_stop
    end

    def boxes
      Enumerator.new do |e|
        cur_pos = @start
        @stream.seek cur_pos
        until @should_stop.call @stream
          box = FileData::Box.new
          box.read(@stream)

          e.yield box
          cur_pos += box.size
          @stream.seek cur_pos
        end
      end.lazy
    end

    def self.for_file(stream)
      BoxesReader.new(stream, 0, lambda { |s| s.eof? })
    end

    def self.for_box(stream, box)
      for_position(stream, box.content_pos, box.content_size)
    end

    def self.for_position(stream, pos, size)
      BoxesReader.new(stream, pos, lambda { |s| s.pos >= pos + size})
    end
  end
end
