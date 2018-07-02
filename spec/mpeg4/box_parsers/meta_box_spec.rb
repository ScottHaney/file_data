require 'file_data/formats/mpeg4/box_parsers/meta_box'
require 'support/test_stream'
require 'file_data/helpers/stream_view'
require 'time'

RSpec.describe FileData::MetaBoxParser do
  let(:view) do
    v = Helpers::StreamView.new(TestStream.get_stream(bytes))
    v.seek(v.start_pos)
    return v
  end
  let(:box) { FileData::MetaBoxParser.parse(view) }

  describe '#parse' do
    context 'when there is an apple creation date value' do
      let(:time) { Time.new(2018, 1, 1) }
      let(:bytes) do
        apple_key = 'com.apple.quicktime.creationdate'.each_byte.map { |x| x }
        time_str = time.to_s

        [[0, 0, 0, 24 + apple_key.length], # keys box size
         'keys'.each_byte.map { |x| x }, # keys box type 'keys'
         [0], # version
         [0, 0, 0], # flags
         [0, 0, 0, 1], # entry count
         [0, 0, 0, 8 + apple_key.length], # key1 size
         [0, 0, 0, 0], # key1 namespace
         apple_key, # key1 value of apple_key
         [0, 0, 0, 32 + time_str.length], # ilst box size
         'ilst'.each_byte.map { |x| x }, # ilst box type 'ilst'
         [0, 0, 0, 24 + time_str.length], # ilst entry size
         [0, 0, 0, 1], # index
         [0, 0, 0, 16 + time_str.length], # data box size
         [100, 97, 116, 97], # data box type 'data'
         [0, 0, 0, 1], # data box data type
         [0, 0, 0, 1], # locale
         time_str.each_byte.map { |x| x }].flatten # string value of the time
      end

      it 'gets the time value' do
        expect(box.creation_date).to eq(time)
      end
    end

    context 'when there is not an apple creation date value' do
      let(:bytes) do
        custom_key = 'com.test.temp.whatever'.each_byte.map { |x| x }
        custom_str = 'testing'
        custom_bytes = custom_str.each_byte.map { |x| x }

        [[0, 0, 0, 24 + custom_key.length], # keys box size
         'keys'.each_byte.map { |x| x }, # keys box type 'keys'
         [0], # version
         [0, 0, 0], # flags
         [0, 0, 0, 1], # entry count
         [0, 0, 0, 8 + custom_key.length], # key1 size
         [0, 0, 0, 0], # key1 namespace
         custom_key, # key1 value of apple_key
         [0, 0, 0, 32 + custom_bytes.length], # ilst box size
         'ilst'.each_byte.map { |x| x }, # ilst box type 'ilst'
         [0, 0, 0, 24 + custom_bytes.length], # ilst entry size
         [0, 0, 0, 1], # index
         [0, 0, 0, 16 + custom_bytes.length], # data box size
         [100, 97, 116, 97], # data box type 'data'
         [0, 0, 0, 1], # data box data type
         [0, 0, 0, 1], # locale
         custom_bytes].flatten # string value of the time
      end

      it 'gets the time value' do
        expect(box.creation_date).to be_nil
      end
    end
  end
end
