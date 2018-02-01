require_relative 'box_stream'
require_relative '../../core_extensions/binary_extensions'
require 'date'

module FileData
  class Mpeg4
    include BinaryExtensions

    def creation_date(stream)
      FileData::BoxStream.new(stream).boxes.each do |box|
        if (box.type == "moov")
          FileData::BoxSubStream.new(stream, box).boxes.each do |sub_box|
            if (sub_box.type == "mvhd")
              version = read_value(1, stream)
              flags = read_value(3, stream)
          
              creation_time = read_value(version == 1 ? 8 : 4, stream)
              epoch_delta = 2082844800
              return Time.at(creation_time - epoch_delta)
            end
          end
        end
      end
    end
  end
end
    
