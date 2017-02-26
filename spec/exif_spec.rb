require 'fakefs/spec_helpers'
require 'support/test_stream'
require 'file_data/data_formats/exif'
require 'file_data/data_formats/exif_stream'

RSpec.describe FileData::Exif do
  let(:exif) { FileData::Exif.new(FileData::ExifStream.new(stream)) }
  let(:exif_from_stream) { FileData::Exif.from_stream(stream) }
  let(:stream) { TestStream.get_stream(test_bytes) }

  let(:both_ifds_test) do
    [77, 77, [0, 42], #Exif header
    [0, 0, 0, 8], [0, 1], # IFD0 offset and tag count
    [1, 0], [0, 3], [0, 0, 0, 2], [0, 0, 0, 1], # IFD0 Tag
    [0, 0, 0, 26], [0, 1], # IFD1 offset and tag count
    [1, 1], [0, 3], [0, 0, 0, 2], [0, 0, 0, 2], # IFD1 Tag
    [0, 0, 0, 0]].flatten # No next IFD marker
  end

  describe ".from_stream" do
    context 'given a jpeg stream without an exif section'
      let(:test_bytes) { [255, 216, 255, 225, 0, 2, 255, 217] }

      it 'can process the jpeg stream' do
        expect { exif_from_stream }.to_not raise_error
      end
  end

  context 'when the exif stream is empty' do
    let(:test_bytes) { [] }

    describe '#image_data_only' do
      it 'delegates to exif_tags_internal(0)' do
        data = FileData::ExifData.new
        expect(data).to receive(:image)
        expect(exif).to receive(:exif_tags_internal).with(0) { data }
        exif.image_data_only
      end
    end

    describe '#thumbnail_data_only' do
      it 'delegates to exif_tags_internal(1)' do
        data = FileData::ExifData.new
        expect(data).to receive(:thumbnail)
        expect(exif).to receive(:exif_tags_internal).with(1) { data }
        exif.thumbnail_data_only
      end
    end

    describe '#all_data' do
      it 'delegates to exif_tags_internal(0, 1)' do
        expect(exif).to receive(:exif_tags_internal).with(0, 1)
        exif.all_data
      end
    end

    describe '#only_image_tag' do
      it 'delegates to exif_tag_internal(0, tag_id)' do
        expect(exif).to receive(:exif_tag_internal).with(0, [:xyz, 500])
        exif.only_image_tag([:xyz, 500])
      end
    end

    describe '#only_thumbnail_tag' do
      it 'delegates to exif_tag_internal(input, 1, tag_id)' do
        expect(exif).to receive(:exif_tag_internal).with(1, [:xyz, 500])
        exif.only_thumbnail_tag([:xyz, 500])
      end
    end
  end

  describe '#tags' do
    let(:tags_from_stream) { exif_from_stream.tags(*ifds_to_include) }
    let(:tags) { exif.tags(*ifds_to_include) }

    context 'when there is no exif data' do
      let(:test_bytes) { [255, 216, 255, 225, 0, 2, 255, 217] }
      let(:ifds_to_include) { [0, 1] }

      it 'returns an empty collection' do
        expect(tags_from_stream.to_a).to be_empty
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
              [77, 77, [0, 42], #Exif header
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

    describe '#exif_tag_internal' do
      let(:exif_tag_internal) { exif.exif_tag_internal(ifd_index, tag_to_find) }
      let(:test_bytes) { both_ifds_test }
      let(:ifd_index) { 0 }

      context 'when there are two tags' do
        describe 'and searching for a tag that is found' do
          let(:tag_to_find) { [:Tiff, 256] }

          it "returns the tag's value" do
            expect(exif_tag_internal).to eq(1)
          end
        end

        describe 'and searching for a tag that is not found' do
          let(:tag_to_find) { [:xyz, 4000] }

          it 'returns nil' do
            expect(exif_tag_internal).to be nil
          end
        end
      end
    end

    describe '#exif_tags_internal' do
      let(:exif_tags_internal) { exif.exif_tags_internal(*ifds_to_include) }

      context 'when there is one image tag' do
        context 'and there is one thumbnail tag' do
          let(:test_bytes) { both_ifds_test }

          describe 'and only image data should be returned' do
            let(:ifds_to_include) { [0] }

            it 'returns a hash containing the tag and value' do
              data = exif_tags_internal
              expect(data.image).to eq(Image_Structure_Width: 1)
              expect(data.thumbnail).to be_empty
            end
          end

          describe 'and only thumbnail data should be returned' do
            let(:ifds_to_include) { [1] }

            it 'returns a hash containing the tag and value' do
              data = exif_tags_internal
              expect(data.image).to be_empty
              expect(data.thumbnail).to eq(Image_Structure_Length: 2)
            end
          end

          describe 'and all data should be returned' do
            let(:ifds_to_include) { [0, 1] }

            it 'returns a hash containing the tag and value' do
              data = exif_tags_internal
              expect(data.image).to eq(Image_Structure_Width: 1)
              expect(data.thumbnail).to eq(Image_Structure_Length: 2)
            end
          end
        end
      end
    end
  end
end