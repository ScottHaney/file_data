require 'file_data/data_formats/exif_tags'

RSpec.describe FileData::ExifTags do
  let(:exif_tags) { FileData::ExifTags }

  describe '.get_tag_name' do
    let(:get_tag_name) { exif_tags.get_tag_name(ifd_id, tag_id) }

    describe 'when the tag has a known name' do
      let(:ifd_id) { 34_853 }
      let(:tag_id) { 0 }

      it 'returns the known name' do
        expect(get_tag_name).to eq(:GPS_Version)
      end
    end

    describe 'when the ifd id does not have a known name' do
      let(:ifd_id) { 555 }
      let(:tag_id) { 12 }

      it 'returns the ifd id and tag id joined together by a hyphen' do
        expect(get_tag_name).to eq(:'555-12')
      end
    end

    describe 'when the ifd id has a known name' do
      let(:ifd_id) { :Tiff }

      describe 'and the tag id does not have a known name' do
        let(:tag_id) { 0 }

        it 'returns the ifd name and tag id joined together by a hyphen' do
          expect(get_tag_name).to eq(:'Tiff-0')
        end
      end
    end
  end
end
