module FileData
  # Mpeg4 reader
  class Box
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

      def read_value(num_bytes, stream)
        bytes = stream.each_byte.take(num_bytes)
        bytes.inject { |total, val| (total << 8) + val }
      end
  end
end
