require_relative '../boxes_reader'
require_relative '../../../helpers/stream_view'
require_relative 'ilst_data_box'

module FileData
  # Parsers for the 'ilst' box
  class IlstBoxParser
    def self.parse(view)
      size = view.read_value(4)
      index = view.read_value(4)

      db = find_data_box(view, size)
      data_box = db.nil? ? nil : IlstDataBoxParser.parse(db)

      IlstBox.new(index, data_box)
    end

    def self.find_data_box(parent_view, parent_size)
      view = Helpers::SubStreamView.new(parent_view.stream, parent_view.stream.pos, parent_size - 8)
      BoxesReader.read(view).find { |box| box.type == 'data' }
    end
  end

  IlstBox = Struct.new(:index, :data_box)
end
