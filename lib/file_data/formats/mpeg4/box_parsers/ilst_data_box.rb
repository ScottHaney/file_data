module FileData
  # Parser for the 'data' box
  class IlstDataBoxParser
    def self.parse(box)
      view = box.content_stream

      # TO DO - Currently a text value is always assumed...
      data_type = view.read_value(4)
      locale = view.read_value(4)
      value = view.read_ascii(view.remaining_bytes)

      DataBox.new(data_type, locale, value)
    end
  end

  DataBox = Struct.new(:data_type, :locale, :value_text)
end
