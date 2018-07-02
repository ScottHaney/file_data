require 'support/test_stream'
require 'file_data/helpers/stream_view'

RSpec.describe Helpers::StreamView do
  let(:view) do
    v = Helpers::StreamView.new(TestStream.get_stream(test_bytes))
    v.seek(v.start_pos)
    return v
  end

  let(:test_bytes) { [0, 1, 2, 3] }

  describe '#start_pos' do
    it 'is set to zero when the instance is constructed' do
      expect(view.start_pos).to eq(0)
    end
  end

  describe '#eof' do
    it 'is true when all bytes have been read' do
      view.each_byte.take(test_bytes.length)
      expect(view.eof?).to be true
    end

    context 'when given a non-empty stream' do
      it 'is false when no bytes have been read' do
        expect(view.eof?).to be false
      end
    end
  end
end

RSpec.describe Helpers::SubStreamView do
  let(:view) do
    v = Helpers::SubStreamView.new(TestStream.get_stream(test_bytes), start, size)
    v.seek(v.start_pos)
    return v
  end

  let(:test_bytes) { [1, 2, 3, 4] }
  let(:start) { 1 }
  let(:size) { 2 }

  describe '#remaining_bytes' do
    let(:remaining_bytes) { view.remaining_bytes }

    context 'when no bytes have been read' do
      it 'is the full size of the view' do
        expect(remaining_bytes).to eq(size)
      end
    end

    context 'when a single byte has been read' do
      it 'is one less than the full size of the view' do
        view.each_byte.take(1)
        expect(remaining_bytes).to eq(size - 1)
      end
    end
  end

  describe '#eof' do
    it 'is true when all bytes have been read' do
      view.each_byte.take(view.size)
      expect(view.eof?).to be true
    end

    context 'when given a non-empty stream' do
      it 'is false when no bytes have been read' do
        expect(view.eof?).to be false
      end
    end
  end
end
