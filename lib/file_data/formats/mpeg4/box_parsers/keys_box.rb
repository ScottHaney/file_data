require_relative '../../../helpers/sized_field'

module FileData
  # Parser for the 'keys' box
  class KeysBoxParser
    def self.parse(view)
      view.read_value(1) # version field
      view.read_value(3) # flags field

      entry_count = view.read_value(4)
      Array.new(entry_count) { |index| parse_key(view, index) }
    end

    def self.parse_key(view, index)
      key_view = Helpers::SizedField.create_view(view, 4)
      namespace = key_view.read_ascii(4)
      value = key_view.read_ascii(key_view.remaining_bytes)

      Key.new(index + 1, namespace, value)
    end
  end

  Key = Struct.new(:index, :namespace, :value)
end
