require 'support/test_stream'
require 'file_data/file_types/file_info'
require 'file_data/formats/exif/exif'
require 'file_data/formats/mpeg4/mpeg4'

RSpec.describe FileData::FileInfo do
  let(:file_info) { FileData::FileInfo }

  describe '.can_handle?' do
    let(:can_handle) { file_info.can_handle?(filename) }

    context 'when given a file with a .jpg extension' do
      let(:filename) { 'test.jpg' }
      it 'returns true' do
        expect(can_handle).to be true
      end
    end

    context 'when given a file with a .m4v extension' do
      let(:filename) { 'test.m4v' }
      it 'returns true' do
        expect(can_handle).to be true
      end
    end

    context 'when given a file with an unrecognized extension' do
      let(:filename) { 'test.oiuj@%owfda2' }
      it 'returns false' do
        expect(can_handle).to be false
      end
    end
  end
end
