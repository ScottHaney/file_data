require 'fakefs/spec_helpers'
require 'file_data/file_types/file_info'
require 'file_data/formats/exif/exif'
require 'support/test_stream'

RSpec.describe FileData::Exif do
  let(:exif) { FileData::Exif }
  let(:both_ifds_test) do
    [255, 216, # JPEG SOI
     255, 225, 0, 52, # APP1 marker and size
     69, 120, 105, 102, 0, 0, # Exif\0\0 marker
     [77, 77], [0, 42], # Exif header (big endian)
     [0, 0, 0, 8], [0, 1], # IFD0 offset and tag count
     [1, 0], [0, 3], [0, 0, 0, 2], [0, 0, 0, 1], # IFD0 Tag
     [0, 0, 0, 26], [0, 1], # IFD1 offset and tag count
     [1, 1], [0, 3], [0, 0, 0, 2], [0, 0, 0, 2], # IFD1 Tag
     [0, 0, 0, 0], # No next IFD marker
     255, 217].flatten # JPEG EOI
  end
  let(:stream) { TestStream.get_stream(both_ifds_test) }

  context 'tests using the fake file system helpers' do
    include FakeFS::SpecHelpers

    describe '#image_data_only' do
      context 'when given an input stream' do
        it 'reads the image data' do
          expect(FileData::Exif.image_data_only(stream)[:Image_Structure_Width]).to eq(1)
        end

        it 'succeeds in passing a missing method on ExifHash down to the inner hash object' do
          image_data = exif.image_data_only(stream)
          expect(image_data.keys).to match_array([:Image_Structure_Width])
        end
      end

      context 'when given an input file' do
        let(:test_file) { '/test.jpg' }
        before do
          File.open(test_file, 'w') { |f| f.write both_ifds_test.pack('C*') }
        end

        it 'reads the image data' do
          image_data = exif.image_data_only(test_file)
          expect(image_data[:Image_Structure_Width]).to eq(1)
          expect(image_data.width).to eq(1)
        end
      end
    end

    describe '#thumbnail_data_only' do
      context 'when given an input stream' do
        it 'reads the thumbnail data' do
          thumbnail_data = exif.thumbnail_data_only(stream)
          expect(thumbnail_data[:Image_Structure_Length]).to eq(2)
          expect(thumbnail_data.length).to eq(2)
        end
      end

      context 'when given an input file' do
        let(:test_file) { '/test.jpg' }
        before do
          File.open(test_file, 'w') { |f| f.write both_ifds_test.pack('C*') }
        end

        it 'reads the thumbnail data' do
          thumbnail_data = exif.thumbnail_data_only(test_file)
          expect(thumbnail_data[:Image_Structure_Length]).to eq(2)
          expect(thumbnail_data.length).to eq(2)
        end
      end
    end

    describe '#all_data' do
      context 'when given an input stream' do
        it 'reads the image data' do
          result = exif.all_data(stream)

          expect(result.image[:Image_Structure_Width]).to eq(1)
          expect(result.image.width).to eq(1)

          expect(result.thumbnail[:Image_Structure_Length]).to eq(2)
          expect(result.thumbnail.length).to eq(2)
        end
      end
    end

    describe '#only_image_tag' do
      context 'when given an input stream' do
        it 'reads the image data' do
          expect(exif.only_image_tag(stream, [:Tiff, 256])).to eq(1)
        end
      end
    end

    describe '#only_thumbnail_tag' do
      context 'when given an input stream' do
        it 'reads the image data' do
          expect(exif.only_thumbnail_tag(stream, [:Tiff, 257])).to eq(2)
        end
      end
    end

    describe '#creation_date' do
      context 'given an image without a creation date tag' do
        it 'returns nil' do
          expect(exif.creation_date(stream)).to be_nil
        end
      end
    end
  end

  describe 'file extension mappings' do
    it 'adds the expected mappings to FileInfo' do
      load 'file_data/formats/exif/exif.rb'
      expect(FileData::FileInfo.info_maps['.jpeg']).to be_truthy
      expect(FileData::FileInfo.info_maps['.jpg']).to be_truthy
    end
  end
end
