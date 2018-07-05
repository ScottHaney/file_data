require 'file_data/file_types/file_info'
require 'file_data/formats/mpeg4/mpeg4'
require 'file_data/formats/mpeg4/box_parsers/mvhd_box'
require 'support/test_stream'
require 'time'

RSpec.describe FileData::Mpeg4 do
  let(:mpeg4) { FileData::Mpeg4 }
  let(:stream) { TestStream.get_stream(test_bytes) }

  describe '#get_value' do
    let(:test_bytes) do
      [[0, 0, 0, 24], # Box size
       [109, 111, 111, 118], # Box type of moov
       [0, 0, 0, 16], # Size
       [109, 118, 104, 100], # Box type of mvhd
       [2], # Version
       [0, 0, 0], # Flags
       [210, 234, 90, 151]].flatten # Time of 2016-02-17 17:12:55
    end

    context 'when given a box path that does not exist' do
      it 'returns nil' do
        expect(mpeg4.get_value(stream, nil, nil, 'dne')).to be_nil
      end
    end

    context 'when given a box path that does exist' do
      it 'returns the expected value' do
        expect(mpeg4.get_value(stream, FileData::MvhdBoxParser, 'creation_time', 'moov', 'mvhd')).to eq(Time.new(2016, 2, 17, 17, 12, 55))
      end
    end
  end

  describe 'generated methods' do
    context 'a creation_date method is generated' do
      let(:test_bytes) do
        [[0, 0, 0, 24], # Box size
         [109, 111, 111, 118], # Box type of moov
         [0, 0, 0, 16], # Size
         [109, 118, 104, 100], # Box type of mvhd
         [2], # Version
         [0, 0, 0], # Flags
         [210, 234, 90, 151]].flatten # Time of 2016-02-17 17:12:55
      end
    
      it 'extracts the creation date' do
        expect(mpeg4.creation_date(stream)).to eq(Time.new(2016, 2, 17, 17, 12, 55))
      end
    end
  end

  # context 'Given an actual file' do
  #   let(:stream) { File.open('/home/ubuntu/code/IMG_4537.m4v', 'rb') }
  #   it 'Reports the creation date' do
  #     date = FileData::Mpeg4.origin_date(stream)
  #     puts 'Origin Year: ' + date.year.to_s
  #     puts 'Origin Month: ' + date.month.to_s
  #     puts 'Origin Day: ' + date.day.to_s
  #     puts 'Origin Date: ' + date.to_s
  #     date2 = FileData::Mpeg4.creation_date(stream)
  #     puts 'Creation Date: ' + date2.to_s
  #   end
  # end
end
