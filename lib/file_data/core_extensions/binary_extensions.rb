# Methods for reading values from a binary stream
module BinaryExtensions
  def read_value(num_bytes, stream)
    bytes = stream.each_byte.take(num_bytes)
    bytes.inject { |total, val| (total << 8) + val }
  end

  def read_ascii(num_bytes, stream)
    stream.each_byte.take(num_bytes).map(&:chr).join
  end
end
