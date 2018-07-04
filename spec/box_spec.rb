require 'file_data/formats/mpeg4/box'
require 'support/test_stream'
require 'file_data/helpers/stream_view'

RSpec.describe FileData::Box do
  let(:view) { TestStream.get_stream(bytes) }
  let(:box) { FileData::Box.parse(view) }

  describe '#parse' do
    context 'when the first field contains the size of the box' do
      let(:bytes) do
        [[0, 0, 0, 12], # size
         [100, 97, 116, 97], # type
         [0, 0, 0, 14]].flatten # content
      end

      it 'creates the box' do
        expect(box.type).to eq('data')
        expect(box.content_stream.start_pos).to eq(8)
        expect(box.content_stream.end_pos).to eq(11)
        expect(box.content_stream.size).to eq(4)
      end
    end

    context 'when more than one field is needed for the size of the box' do
      let(:bytes) do
        [[0, 0, 0, 1], # size field 1
        [100, 97, 116, 97], # type
         [0, 0, 0, 0, 0, 0, 0, 20], # size field 2
         [100, 97, 116, 97]].flatten # content
      end

      it 'gets the value stored in the data box' do
        expect(box.type).to eq('data')
        expect(box.content_stream.start_pos).to eq(16)
        expect(box.content_stream.end_pos).to eq(19)
        expect(box.content_stream.size).to eq(4)
      end
    end
  end
end
