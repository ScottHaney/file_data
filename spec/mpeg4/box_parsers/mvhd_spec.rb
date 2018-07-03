require 'file_data/formats/mpeg4/box_parsers/mvhd_box'
require 'support/test_stream'
require 'file_data/helpers/stream_view'
require 'time'

RSpec.describe FileData::MvhdBoxParser do
  let(:view) do
    v = Helpers::StreamView.new(TestStream.get_stream(bytes))
    v.seek(v.start_pos)
    return v
  end
  let(:box) { FileData::MvhdBoxParser.parse(view) }

  describe '#parse' do
    context 'when there is an eight byte long creation date' do
      let(:time) { Time.at(-2_082_844_800) }
      let(:bytes) do
        [1, # version
         [0, 0, 0], # flags bytes
         [0, 0, 0, 0, 0, 0, 0, 0]].flatten # creation time since epoch
      end

      it 'gets the creation date' do
        expect(box.creation_time).to eq(time)
      end
    end
  end
end
