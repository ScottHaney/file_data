require 'file_data/formats/mpeg4/box_path'
require 'support/test_stream'
require 'file_data/helpers/stream_view'

RSpec.describe FileData::BoxPath do
  let(:view) do
    v = Helpers::StreamView.new(TestStream.get_stream(bytes))
    v.seek(v.start_pos)
    return v
  end

  describe '#get_path' do
    context 'when searching for a path that does not exist' do
      let(:bytes) do
        [[0, 0, 0, 8], # keys box size
         'keys'.each_byte.map { |x| x }, # keys box type 'keys'
         [0, 0, 0, 24], # container box size
         'cbss'.each_byte.map { |x| x }, # container box type
         [0, 0, 0, 8], # item1 box size
         'itm1'.each_byte.map { |x| x }, # item1 box type
         [0, 0, 0, 8], # item2 box size
         'itm2'.each_byte.map { |x| x }].flatten # item2 box type
      end

      it 'returns nil' do
        expect(FileData::BoxPath.get_path(view, 'cbss', 'itm1', 'nope')).to be_nil
      end
    end

    context 'when searching for a path that does exist' do
      let(:bytes) do
        [[0, 0, 0, 8], # keys box size
         'keys'.each_byte.map { |x| x }, # keys box type 'keys'
         [0, 0, 0, 24], # container box size
         'cbss'.each_byte.map { |x| x }, # container box type
         [0, 0, 0, 8], # item1 box size
         'itm1'.each_byte.map { |x| x }, # item1 box type
         [0, 0, 0, 8], # item2 box size
         'itm2'.each_byte.map { |x| x }].flatten # item2 box type
      end

      it 'finds the box' do
        expect(FileData::BoxPath.get_path(view, 'cbss', 'itm1').type).to eq('itm1')
      end
    end
  end
end
