require_relative '../../core_extensions/binary_extensions'

module FileData
  # Mpeg4 box
  class Box
      include BinaryExtensions

      attr_reader :size, :type

      # Read the header
      def read(stream)
        first_field = read_value(4, stream)
        @type = stream.each_byte.take(4).map { |b| b.chr }.join

        @size =
          if first_field == 1
            read_value(8, stream)
          else
            first_field
          end
      end
  end
end
