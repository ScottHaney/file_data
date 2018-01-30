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
end
