require 'file_data/formats/mpeg4/box_parsers/ilst_box'
require 'support/test_stream'
require 'file_data/helpers/stream_view'

RSpec.describe FileData::IlstBoxParser do
  let(:view) do
    v = Helpers::StreamView.new(TestStream.get_stream(bytes))
    v.seek(v.start_pos)
    return v
  end
  let(:box) { FileData::IlstBoxParser.parse(view) }

  describe '#parse' do
    context 'when the box has only an index field' do
      let(:bytes) do
        [[0, 0, 0, 8], # size
         [0, 0, 0, 1]].flatten # index
      end

      it 'parses the correct index value' do
        expect(box.index).to eq(1)
      end
    end

    context 'when the box has a data box as content' do
      let(:bytes) do
        [[0, 0, 0, 29], # ilst box size
         [0, 0, 0, 1], # index
         [0, 0, 0, 21], # data box size
         [100, 97, 116, 97], # data box type 'data'
         [0, 0, 0, 1], # data box data type
         [0, 0, 0, 1], # locale
         [116, 97, 100, 97, 33]].flatten # data value of 'tada!'
      end

      it 'gets the value stored in the data box' do
        expect(box.data_box.value_text).to eq('tada!')
      end
    end
  end
end
