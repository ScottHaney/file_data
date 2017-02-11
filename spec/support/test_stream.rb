# Used for creating a simple StringIO test stream from a byte array
class TestStream
  def self.get_stream(bytes)
    StringIO.open(bytes.pack('C*'))
  end
end
