require 'support/test_stream'
require 'file_data/file_types/jpeg'

RSpec.describe FileData::Jpeg do
  let(:jpeg) { FileData::Jpeg }
  let(:stream) { TestStream.get_stream(test_bytes) }

  describe '#each_section' do
    let(:each_section) { jpeg.each_section(stream) }

    context 'when the jpeg SOI bytes are missing' do
      let(:test_bytes) { [255, 215] }
      it 'throws an exception' do
        expect { each_section.to_a }.to raise_error(RuntimeError)
      end
    end

    context 'when there are two jpeg sections' do
      let(:no_eoi_bytes) { [255, 216, 255, 1, 0, 2, 255, 2, 0, 2] }

      context 'and there are no jpeg EOI bytes' do
        let(:test_bytes) { no_eoi_bytes }
        it 'returns both jpeg sections' do
          expect(each_section.to_a).to eq([[[255, 1], 2], [[255, 2], 2]])
        end
      end

      context 'and the jpeg EOI bytes exist' do
        let(:test_bytes) { no_eoi_bytes + [255, 217] }
        it 'returns both jpeg sections' do
          expect(each_section.to_a).to eq([[[255, 1], 2], [[255, 2], 2]])
        end
      end
    end
  end
end
