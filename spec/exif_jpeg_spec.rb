require 'support/test_stream'
require 'file_data/formats/exif/exif_jpeg'

RSpec.describe FileData::ExifJpeg do
  let(:exif_jpeg) { FileData::ExifJpeg.new(stream) }
  let(:stream) { TestStream.get_stream(test_bytes) }

  describe '#exif' do
    let(:each_section) { jpeg.each_section }

    context 'when there is no exif section' do
      let(:test_bytes) do
        [[255, 216], # SOI bytes
         [255, 1, 0, 2], # Section 1
         [255, 2, 0, 2], # Section 2
         [255, 217]].flatten # EOI bytes
      end

      it 'returns nil' do
        expect(exif_jpeg.exif).to be_nil
      end
    end

    context 'when there is an exif section' do
      let(:test_bytes) do
        exif_marker = "Exif\0\0"
        [[255, 216], # SOI bytes
         [255, 1, 0, 2], # Section 1
         [255, 225, 0, 2 + exif_marker.length], # Exif section part 1
         exif_marker.bytes.to_a, # Exif section part 2
         [255, 217]].flatten # EOI bytes
      end

      it 'returns an exif stream' do
        expect(exif_jpeg.exif.pos).to eq(16)
      end
    end
  end
end
