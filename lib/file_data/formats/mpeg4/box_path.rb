require_relative 'boxes_reader'

module FileData
  class BoxPath
    def self.get_root_path(stream, *box_path)
      get_path(Helpers::StreamView.new(stream), *box_path)
    end

    # def self.get_box_path(box, *box_path)
    #   get_path(box.content_stream, *box_path)
    # end

    def self.get_path(stream_view, *box_path)
      match = BoxesReader.read(stream_view).find { |x| x.type == box_path[0] }

      if match.nil?
        nil
      elsif box_path.length == 1
        match
      else
        get_path(match.content_stream, *box_path[1..-1])
      end
    end
  end
end