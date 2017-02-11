require 'support/test_stream'
require 'file_data/file_types/jpeg'

RSpec.describe FileData::Exif do
  let(:jpeg) { FileData::Jpeg }
  let(:stream) { TestStream.get_stream(test_bytes) }

  describe '.read_header' do
    let(:read_header) { jpeg.read_header(stream) }

    context 'when given a file with a jpeg header' do
      let(:test_bytes) { [255, 216] }
      it { expect { read_header }.not_to raise_error }
    end

    context 'when given a file with a header that is NOT a valid jpeg header' do
      let(:test_bytes) { [255, 215] }
      it { expect { read_header }.to raise_error(RuntimeError) }
    end
  end

  describe '.read_section_header' do
    describe 'with a size of 258 bytes' do
      let(:test_bytes) { [[255, 224], [1, 2]].flatten }
      it { expect(jpeg.read_section_header(stream)).to eq([[255, 224], 258]) }
    end
  end

  describe '.each_section' do
    describe 'with two sections of 4 and 6 bytes in size respectively' do
      let(:test_bytes) { [[255, 216], [255, 224], [0, 4], [0, 0], [255, 225], [0, 6], [0, 0, 0, 0], [255, 217]].flatten }
      it { expect(jpeg.each_section(stream).to_a).to eq([[[255, 224], 4], [[255, 225], 6]]) }
    end
  end
end
