require 'file_data/data_formats/exif_stream'
require 'support/test_stream'

RSpec.describe FileData::ExifStream do
  let(:exif_stream) { FileData::ExifStream.new(stream) }
  let(:stream) { TestStream.get_stream(test_bytes) }

  describe '#read_header' do
    let(:read_header) { exif_stream.read_header }

    context 'given a valid big endian header' do
      let(:test_bytes) { [77, 77, 0, 42] }

      it 'sets @is_big_endian to true' do
        read_header
        expect(exif_stream.instance_variable_get(:@is_big_endian)).to be true
      end
    end

    context 'given a valid little endian header' do
      let(:test_bytes) { [73, 73, 42, 0] }

      it 'sets @is_big_endian to false' do
        read_header
        expect(exif_stream.instance_variable_get(:@is_big_endian)).to be false
      end
    end

    context 'given an unrecognized endianess marker' do
      let(:test_bytes) { [4, 5, 42, 0] }

      it 'throws an exception' do
        expect { read_header }.to raise_error(RuntimeError)
      end
    end

    context 'given a valid endianess but an invalid 42 marker' do
      let(:test_bytes) { [73, 73, 0, 0] }

      it 'throws an exception' do
        expect { read_header }.to raise_error(RuntimeError)
      end
    end
  end

  # Each test in this block is repeated for both little and big endian byte orders
  [['little endian', true], ['big endian', false]].each do |endian_name, is_big_endian|
    context "given that exif data is in the #{endian_name} layout" do
      # Converts big_endian_test_bytes for an example into the proper endianess.
      # Entries that are Arrays are affected by endianess and entries that are numbers are not.
      let(:test_bytes) do
        endian_bytes =
          if is_big_endian
            big_endian_test_bytes
          else
            big_endian_test_bytes.map { |v| v.is_a?(Array) ? v.reverse : v }
          end
        endian_bytes.flatten
      end

      describe '#read_tag_value' do
        shared_examples_for 'a tag record that has a value of' do |value|
          it do
            es = exif_stream
            es.instance_variable_set(:@is_big_endian, is_big_endian)
            expect(es.read_tag_value).to eq(value)
          end
        end

        describe 'that is a TYPE_BYTE record' do
          let(:big_endian_test_bytes) { [[0, 1], [0, 0, 0, 1], [0, 0, 0, 128]] }
          it_behaves_like 'a tag record that has a value of', 2**7
        end

        describe 'that is a TYPE_SHORT record' do
          let(:big_endian_test_bytes) { [[0, 3], [0, 0, 0, 2], [0, 0, 1, 0]] }
          it_behaves_like 'a tag record that has a value of', 2**8
        end

        describe 'that is a TYPE_LONG record' do
          let(:big_endian_test_bytes) { [[0, 4], [0, 0, 0, 4], [128, 0, 0, 0]] }
          it_behaves_like 'a tag record that has a value of', 2**31
        end

        describe 'that is a TYPE_SLONG record' do
          let(:big_endian_test_bytes) { [[0, 9], [0, 0, 0, 4], [128, 0, 0, 0]] }
          it_behaves_like 'a tag record that has a value of', -2**31
        end

        describe 'that is a TYPE_RATIONAL record plus the value' do
          let(:big_endian_test_bytes) { [[0, 5], [0, 0, 0, 8], [0, 0, 0, 10], [128, 0, 0, 1], [128, 0, 0, 0]] }
          it_behaves_like 'a tag record that has a value of', "#{2**31 + 1}/#{2**31}"
        end

        describe 'that is a TYPE_SRATIONAL record plus the value' do
          let(:big_endian_test_bytes) { [[0, 10], [0, 0, 0, 8], [0, 0, 0, 10], [128, 0, 0, 1], [128, 0, 0, 0]] }
          it_behaves_like 'a tag record that has a value of', "#{-2**31 + 1}/#{-2**31}"
        end

        describe 'that is a record with an unrecognized type' do
          let(:big_endian_test_bytes) { [[0, 74], [0, 0, 0, 4], [0, 0, 0, 1]] }
          it_behaves_like 'a tag record that has a value of', nil
        end

        describe 'with a value more than 4 bytes long' do
          # raw_value is an array of bytes so that it isn't affected by endianess
          let(:raw_value) { [72, 101, 108, 108, 111, 0] }

          describe 'that is a TYPE_ASCII record plus the value' do
            let(:big_endian_test_bytes) { [[0, 2], [0, 0, 0, 6], [0, 0, 0, 10]] + raw_value }
            it_behaves_like 'a tag record that has a value of', 'Hello'
          end

          describe 'that is a TYPE_UNDEFINED record plus the value' do
            let(:big_endian_test_bytes) { [[0, 7], [0, 0, 0, 6], [0, 0, 0, 10]] + raw_value }
            it_behaves_like 'a tag record that has a value of', [[72, 101, 108, 108, 111, 0], is_big_endian]
          end
        end

        describe 'with a value that is 4 bytes or less long' do
          # raw_value is an array of bytes so that it isn't affected by endianess
          let(:raw_value) { [67, 97, 114, 0] }

          describe 'that is a TYPE_ASCII record' do
            let(:big_endian_test_bytes) { [[0, 2], [0, 0, 0, 4]] + raw_value }
            it_behaves_like 'a tag record that has a value of', 'Car'
          end

          describe 'that is a TYPE_UNDEFINED record' do
            let(:big_endian_test_bytes) { [[0, 7], [0, 0, 0, 4]] + raw_value }
            it_behaves_like 'a tag record that has a value of', [[67, 97, 114, 0], is_big_endian]
          end
        end
      end
    end
  end
end