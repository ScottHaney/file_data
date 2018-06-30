require 'forwardable'

module Helpers
  class BaseStreamView
    extend Forwardable

    attr_reader :stream, :start_pos

    def initialize(stream, start_pos)
      @stream = stream
      @start_pos = start_pos
    end

    def_delegators :@stream, :seek, :each_byte
  end

  class SubStreamView < BaseStreamView
    attr_reader :end_pos, :size

    def initialize(stream, start_pos, size)
      super(stream, start_pos)
      @end_pos = @start_pos + size - 1
      @size = size
    end

    def remaining_bytes
      @end_pos - @stream.pos + 1
    end

    def eof?
      @stream.pos > @end_pos
    end
  end

  class StreamView < BaseStreamView
    def initialize(stream)
      super(stream, 0)
    end

    def eof?
      @stream.eof?
    end
  end
end