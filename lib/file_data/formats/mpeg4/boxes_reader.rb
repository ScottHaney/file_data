require_relative 'box'
require_relative '../../helpers/stream_view'

module FileData
  # Returns all boxes starting from the current position of a stream
  class BoxesReader
    def self.read(view)
      Enumerator.new do |e|
        view.seek view.start_pos
        until view.eof?
          box = Box.parse(view.stream)

          e.yield box
          view.seek box.end_pos + 1
        end
      end.lazy
    end
  end
end
