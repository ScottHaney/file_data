require 'file_data/formats/mpeg4/box_parsers/keys_box'
require 'support/test_stream'
require 'file_data/helpers/stream_view'

RSpec.describe FileData::KeysBoxParser do
  let(:view) do
    v = Helpers::StreamView.new(TestStream.get_stream(bytes))
    v.seek(v.start_pos)
    return v
  end
  let(:box) { FileData::KeysBoxParser.parse(view) }
  
  describe '#parse' do
    context 'when the box has two keys' do
      let(:bytes) do
        [[0], # version
         [0, 0, 0], # flags
         [0, 0, 0, 2], # entry count
         [0, 0, 0, 10], # key1 size
         [0, 0, 0, 0], # key1 namespace
         [118, 49], # key1 value 'v1'
         [0, 0, 0, 10], # key2 size
         [0, 0, 0, 0], # key2 namespace
         [118, 50]].flatten # key2 value 'v2'
      end  

      it 'gets the values for both keys' do
        expect(box.length).to eq(2)
        expect(box[0].value).to eq('v1')
        expect(box[1].value).to eq('v2')
      end
    end
  end
end