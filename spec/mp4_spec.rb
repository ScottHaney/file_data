require 'file_data/formats/mpeg4/mpeg4'
require 'support/test_stream'

RSpec.describe FileData::Mpeg4 do
  describe '#creation_date' do
    context 'when given an input file' do
      let(:mpeg4) { FileData::Mpeg4.new }
      let(:test_bytes) do
        [[0,0,0,24], #Box size
         [109,111,111,118], #Box type of moov
         [0,0,0,16], #Size
         [109,111,111,118], #Type
         [1], #Version
         [0,0,0], #Flags
         [210,234,90,151]].flatten #Time of 2016-02-17 17:12:55
      end
      let(:stream) { TestStream.get_stream(test_bytes) }

      it 'extracts the creation date' do
        expect(mpeg4.creation_date(stream)).to eq(Time.new(2016,2,17,17,12,55))
      end
    end
  end
end
