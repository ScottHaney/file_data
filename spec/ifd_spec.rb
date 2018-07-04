require 'file_data/formats/exif/ifd'
require 'file_data/formats/exif/exif_stream'
require 'support/test_stream'

RSpec.describe FileData::Ifd do
  let(:exif) { FileData::Ifd.new(FileData::ExifStream.new(stream)) }
  let(:bytes) do
    [0, 0] #empty ifd
  end
  let(:stream) { TestStream.get_stream(bytes) }
  
  context 'when given an empty ifd' do
    it 'returns an empty array of tags' do
      expect(exif.tags.to_a).to be_empty
    end
  end
end