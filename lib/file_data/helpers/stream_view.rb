require 'forwardable'
require_relative '../core_extensions/binary_extensions'

module Helpers
  # Abstract view of a stream
  class BaseStreamView
    extend Forwardable
    include BinaryExtensions

    attr_reader :stream, :start_pos

    def initialize(stream, start_pos)
      @stream = stream
      @start_pos = start_pos
    end

    def_delegators :@stream, :seek, :each_byte, :pos
  end

  # View of a stream that has a specified size in bytes
  class SubStreamView < BaseStreamView
    attr_reader :end_pos, :size

    def initialize(stream, start_pos, size)
      super(stream, start_pos)
      @end_pos = @start_pos + size - 1
      @size = size
    end

    def remaining_bytes
      @end_pos - pos + 1
    end

    def eof?
      pos > @end_pos or @stream.eof?
    end
  end

  # View of a stream that ends when eof? is true
  class StreamView < BaseStreamView
    def initialize(stream)
      super(stream, 0)
    end

    def eof?
      @stream.eof?
    end
  end
end
