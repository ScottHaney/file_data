require 'fakefs/spec_helpers'
require 'support/test_stream'
require 'file_data/formats/exif/exif_reader'
require 'file_data/formats/exif/exif_stream'

RSpec.describe FileData::ExifReader do
  let(:exif) { FileData::ExifReader.new }
  let(:exif_stream) { FileData::ExifStream.new(TestStream.get_stream(test_bytes)) }

  let(:both_ifds_test) do
    [77, 77, [0, 42], # Exif header
     [0, 0, 0, 8], [0, 1], # IFD0 offset and tag count
     [1, 0], [0, 3], [0, 0, 0, 2], [0, 0, 0, 1], # IFD0 Tag
     [0, 0, 0, 26], [0, 1], # IFD1 offset and tag count
     [1, 1], [0, 3], [0, 0, 0, 2], [0, 0, 0, 2], # IFD1 Tag
     [0, 0, 0, 0]].flatten # No next IFD marker
  end

  # context 'when the exif stream is empty' do
  #   let(:test_bytes) { [] }

  #   describe '#image_data_only' do
  #     it 'delegates to exif_tags_internal(stream, 0)' do
  #       data = FileData::ExifData.new
  #       expect(data).to receive(:image)
  #       expect(exif).to receive(:exif_tags_internal).with(0) { data }
  #       exif.image_data_only
  #     end
  #   end

  #   describe '#thumbnail_data_only' do
  #     it 'delegates to exif_tags_internal(1)' do
  #       data = FileData::ExifData.new
  #       expect(data).to receive(:thumbnail)
  #       expect(exif).to receive(:exif_tags_internal).with(1) { data }
  #       exif.thumbnail_data_only
  #     end
  #   end

  #   describe '#all_data' do
  #     it 'delegates to exif_tags_internal(0, 1)' do
  #       expect(exif).to receive(:exif_tags_internal).with(0, 1)
  #       exif.all_data
  #     end
  #   end

  #   describe '#only_image_tag' do
  #     it 'delegates to exif_tag_internal(0, tag_id)' do
  #       expect(exif).to receive(:exif_tag_internal).with(0, [:xyz, 500])
  #       exif.only_image_tag([:xyz, 500])
  #     end
  #   end

  #   describe '#only_thumbnail_tag' do
  #     it 'delegates to exif_tag_internal(input, 1, tag_id)' do
  #       expect(exif).to receive(:exif_tag_internal).with(1, [:xyz, 500])
  #       exif.only_thumbnail_tag([:xyz, 500])
  #     end
  #   end
  # end

  describe '#tags' do
    let(:tags) { exif.tags(exif_stream, *ifds_to_include) }

    context 'when there is no exif data' do
      let(:exif_stream) { nil }
      let(:ifds_to_include) { [0, 1] }

      it 'returns an empty collection' do
        expect(tags.to_a).to be_empty
      end
    end

    context 'given a stream with image and thumbnail data' do
      let(:test_bytes) { both_ifds_test }

      describe 'when only image data should be included' do
        let(:ifds_to_include) { [0] }

        it 'returns the image data' do
          expect(tags.to_a).to eq([[0, :Tiff, 256]])
        end
      end

      describe 'when only thumbnail data should be included' do
        let(:ifds_to_include) { [1] }

        it 'returns the thumbnail data' do
          expect(tags.to_a).to eq([[1, :Tiff, 257]])
        end
      end

      describe 'when all data should be included' do
        let(:ifds_to_include) { [0, 1] }

        it 'returns the thumbnail data' do
          expect(tags.to_a).to eq([[0, :Tiff, 256], [1, :Tiff, 257]])
        end
      end
    end

    context 'given that there is only image data' do
      context 'which has only one tag' do
        context 'that is an exif ifd pointer tag' do
          context 'which points to an extra exif ifd with one tag' do
            let(:test_bytes) do
              [77, 77, [0, 42], # Exif header
               [0, 0, 0, 8], [0, 1], # IFD0 offset and tag count
               [135, 105], [0, 4], [0, 0, 0, 4], [0, 0, 0, 26], # exif ifd pointer Tag
               [0, 0, 0, 0], [0, 1], # No next IFD marker and exif ifd tag count
               [1, 1], [0, 3], [0, 0, 0, 2], [0, 0, 0, 2], # exif Tag
               [0, 0, 0, 0]].flatten # No next IFD marker
            end
            let(:ifds_to_include) { [0] }

            it 'returns only the tag in the extra exif ifd' do
              expect(tags.to_a).to eq([[0, 34_665, 257]])
            end
          end
        end
      end
    end
  end
end