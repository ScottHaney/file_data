require 'fakefs/spec_helpers'
require 'file_data/file_types/file_info'
require 'file_data/formats/exif/exif'
require 'file_data/formats/mpeg4/mpeg4'

RSpec.describe FileData::FileInfo do
  include FakeFS::SpecHelpers

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

  describe '.origin_date' do
    let(:origin_date) { file_info.origin_date(filename) }
    let(:test_bytes) do
      [255, 216, # JPEG SOI
       [255, 225], [0, 73], # APP1 marker and size
       [69, 120, 105, 102, 0, 0], # Exif\0\0 marker
       [77, 77], [0, 42], # Exif big endian header
       [0, 0, 0, 8], [0, 1], # IFD0 offset and tag count
       [135, 105], [0, 4], [0, 0, 0, 4], [0, 0, 0, 26],
       [0, 0, 0, 0], #No next IFD marker
       [0, 1], #Number of IFD tags
       [144, 3], [0, 2], [0, 0, 0, 19], [0, 0, 0, 44], #Creation Date Tag
       [0, 0, 0, 0], # No next IFD marker
       [50, 48, 49, 56, 58, 48, 49, 58, 50, 48, 32, 49, 50, 58, 48, 48, 58, 48, 48], #Creation Date Value '2018:01:20 12:00:00'
       [255, 217]].flatten #JPEG EOI
    end

    before :example do
      FileUtils.touch filename
      File.open(filename, 'w') do |output|
        test_bytes.each do |byte|
          output.print byte.chr
        end
      end
    end

    context 'given a jpeg file with a creation date of 2018:01:20 12:00:00' do
      let(:filename) { '/test.jpg' }
      
      it 'extracts the creation date from the jpeg file' do
        expect(origin_date).to eq(DateTime.strptime('2018:01:20 12:00:00', '%Y:%m:%d %H:%M:%S'))
      end
    end

    context 'given a file with an unrecognized extension' do
      let(:filename) { '/test.898ancie2' }

      it 'raises an error' do
        expect { origin_date }.to raise_error(RuntimeError, /No metadata parser class found for the file/)
      end
    end
  end
end
