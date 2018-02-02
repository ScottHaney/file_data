require 'file_data/formats/mpeg4/mpeg4'
require 'support/test_stream'

RSpec.describe FileData::Mpeg4 do
  describe '#creation_date' do
    let(:mpeg4) { FileData::Mpeg4.new }
    let(:stream) { TestStream.get_stream(test_bytes) }

    context 'when given an input file with a non-v1 movie header box' do
      let(:test_bytes) do
        [[0, 0, 0, 24], # Box size
         [109, 111, 111, 118], # Box type of moov
         [0, 0, 0, 16], # Size
         [109, 118, 104, 100], # Box type of mvhd
         [2], # Version
         [0, 0, 0], # Flags
         [210, 234, 90, 151]].flatten # Time of 2016-02-17 17:12:55
      end

      it 'extracts the creation date' do
        expect(mpeg4.creation_date(stream)).to eq(Time.new(2016, 2, 17, 17, 12, 55))
      end
    end

    context 'when given an input file with a v1 movie header box' do
      let(:test_bytes) do
        [[0, 0, 0, 24], # Box size
         [109, 111, 111, 118], # Box type of moov
         [0, 0, 0, 16], # Size
         [109, 118, 104, 100], # Box type of mvhd
         [1], # Version
         [0, 0, 0], # Flags
         [0, 0, 0, 0, 210, 234, 90, 151]].flatten # Time of 2016-02-17 17:12:55
      end

      it 'extracts the creation date' do
        expect(mpeg4.creation_date(stream)).to eq(Time.new(2016, 2, 17, 17, 12, 55))
      end
    end
  end
end
