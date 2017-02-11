require 'support/test_stream'
require 'file_data/data_formats/exif'

RSpec.describe FileData::Exif do
  let(:exif) { FileData::Exif.new }
  let(:stream) { TestStream.get_stream(test_bytes) }

  # Each test in this block must be repeated for both little and big endian byte orders
  [['little endian', true], ['big endian', false]].each do |endian_name, is_little_endian|
    describe "using a #{endian_name} stream" do
      # Container that returns the proper bytes for streams that depend on endianess
      let(:endian_vals) do
        h = { endian_marker: [(is_little_endian ? 'II' : 'MM').bytes] }
        h = h.merge(
          int32_bytes:    [[128, 0, 0, 0]],
          rational_bytes: [[128, 0, 0, 1], [128, 0, 0, 0]],

          byte_record:         [[0, 1], [0, 0, 0, 1], [0, 0, 0, 128]],
          short_record:        [[0, 3], [0, 0, 0, 2], [0, 0, 1, 0]],
          long_record:         [[0, 4], [0, 0, 0, 4], [128, 0, 0, 0]],
          slong_record:        [[0, 9], [0, 0, 0, 4], [128, 0, 0, 0]],
          rational_record:     [[0, 5], [0, 0, 0, 8], [0, 0, 0, 10], [128, 0, 0, 1], [128, 0, 0, 0]],
          srational_record:    [[0, 10], [0, 0, 0, 8], [0, 0, 0, 10], [128, 0, 0, 1], [128, 0, 0, 0]],
          unrecognized_record: [[0, 74], [0, 0, 0, 4], [0, 0, 0, 1]],

          small_undef_prefix: [[0, 7], [0, 0, 0, 4]],
          small_ascii_prefix: [[0, 2], [0, 0, 0, 4]],
          large_undef_prefix: [[0, 7], [0, 0, 0, 6], [0, 0, 0, 10]],
          large_ascii_prefix: [[0, 2], [0, 0, 0, 6], [0, 0, 0, 10]],

          app1_body_one_block: [h[:endian_marker], [0, 42], [0, 0, 0, 8], [0, 1], [0, 1], [0, 1], [0, 0, 0, 1], [0, 0, 0, 201], [0, 0, 0, 0]],

          app1_body_two_blocks: [h[:endian_marker], [0, 42], [0, 0, 0, 8], [0, 1], [0, 1], [0, 1], [0, 0, 0, 1], [0, 0, 0, 201], [0, 0, 0, 26],
                                 [0, 1], [0, 2], [0, 1], [0, 0, 0, 1], [0, 0, 0, 202], [0, 0, 0, 0]],

          app1_body_extra_ptr_block: [h[:endian_marker], [0, 42], [0, 0, 0, 8], [0, 1], [135, 105], [0, 4], [0, 0, 0, 4], [0, 0, 0, 26],
                                      [0, 0, 0, 0], [0, 1], [0, 3], [0, 1], [0, 0, 0, 1], [0, 0, 0, 203], [0, 0, 0, 0]]
        )

        h.update(h) { |_k, v| v.map { |i| is_little_endian ? i.reverse : i }.flatten }
      end

      describe '#read_value' do
        let(:test_bytes) { endian_vals[:int32_bytes] }
        it { expect(exif.read_value(stream, 4, is_little_endian)).to eq(2**31) }
      end

      context '#read_rational' do
        let(:read_rational) { exif.read_rational(stream, is_srational, is_little_endian) }
        let(:test_bytes) { endian_vals[:rational_bytes] }

        describe 'given a srational (signed rational)' do
          let(:is_srational) { true }
          it { expect(read_rational).to eq("#{-2**31 + 1}/#{-2**31}") }
        end

        describe 'given a rational (unsigned rational)' do
          let(:is_srational) { false }
          it { expect(read_rational).to eq("#{2**31 + 1}/#{2**31}") }
        end
      end

      context '#read_tag_value' do
        shared_examples_for 'a tag record that has a value of' do |value|
          it { expect(exif.read_tag_value(stream, 0, is_little_endian)).to eq(value) }
        end

        describe 'that is a TYPE_BYTE record' do
          let(:test_bytes) { endian_vals[:byte_record] }
          it_behaves_like 'a tag record that has a value of', 2**7
        end

        describe 'that is a TYPE_SHORT record' do
          let(:test_bytes) { endian_vals[:short_record] }
          it_behaves_like 'a tag record that has a value of', 2**8
        end

        describe 'that is a TYPE_LONG record' do
          let(:test_bytes) { endian_vals[:long_record] }
          it_behaves_like 'a tag record that has a value of', 2**31
        end

        describe 'that is a TYPE_SLONG record' do
          let(:test_bytes) { endian_vals[:slong_record] }
          it_behaves_like 'a tag record that has a value of', -2**31
        end

        describe 'that is a TYPE_RATIONAL record plus the value' do
          let(:test_bytes) { endian_vals[:rational_record] }
          it_behaves_like 'a tag record that has a value of', "#{2**31 + 1}/#{2**31}"
        end

        describe 'that is a TYPE_SRATIONAL record plus the value' do
          let(:test_bytes) { endian_vals[:srational_record] }
          it_behaves_like 'a tag record that has a value of', "#{-2**31 + 1}/#{-2**31}"
        end

        describe 'that is a record with an unrecognized type' do
          let(:test_bytes) { endian_vals[:unrecognized_record] }
          it_behaves_like 'a tag record that has a value of', nil
        end

        describe 'with a value more than 4 bytes long' do
          let(:value) { [72, 101, 108, 108, 111, 0] }

          describe 'that is a TYPE_ASCII record plus the value' do
            let(:test_bytes) { endian_vals[:large_ascii_prefix] + value }
            it_behaves_like 'a tag record that has a value of', 'Hello'
          end

          describe 'that is a TYPE_UNDEFINED record plus the value' do
            let(:test_bytes) { endian_vals[:large_undef_prefix] + value }
            it_behaves_like 'a tag record that has a value of', [[72, 101, 108, 108, 111, 0], is_little_endian]
          end
        end

        describe 'with a value that is 4 bytes or less long' do
          let(:value) { [67, 97, 114, 0] }

          describe 'that is a TYPE_ASCII record' do
            let(:test_bytes) { endian_vals[:small_ascii_prefix] + value }
            it_behaves_like 'a tag record that has a value of', 'Car'
          end

          describe 'that is a TYPE_UNDEFINED record' do
            let(:test_bytes) { endian_vals[:small_undef_prefix] + value }
            it_behaves_like 'a tag record that has a value of', [[67, 97, 114, 0], is_little_endian]
          end
        end
      end

      describe '#process_ifd_block_chain' do
        shared_examples_for 'an ifd chain with tag/value pairs' do |tags|
          it do
            enum = Enumerator.new do |e|
              exif.process_ifd_block_chain(stream, e, 0, 8, is_little_endian)
            end

            expect(enum.to_a).to eq(tags)
          end
        end

        describe 'given an ifd chain with a single block' do
          let(:test_bytes) { endian_vals[:app1_body_one_block] }
          it_behaves_like 'an ifd chain with tag/value pairs', [[1, 201]]
        end

        describe 'given an ifd chain with two blocks' do
          let(:test_bytes) { endian_vals[:app1_body_two_blocks] }
          it_behaves_like 'an ifd chain with tag/value pairs', [[1, 201], [2, 202]]
        end
      end

      describe '#process_exif_section' do
        describe 'a section with one block ifd chain' do
          shared_examples_for 'an exif section with tag/values' do |tags|
            it { expect(exif.process_exif_section(stream).to_a).to eq(tags) }
          end

          describe 'and NO extra exif ifd chain' do
            let(:test_bytes) { endian_vals[:app1_body_one_block] }
            it_behaves_like 'an exif section with tag/values', [[1, 201]]
          end

          describe 'and an extra exif ifd chain' do
            let(:test_bytes) { endian_vals[:app1_body_extra_ptr_block] }
            it_behaves_like 'an exif section with tag/values', [[3, 203]]
          end
        end
      end

      describe '#read_tags' do
        let(:all_tags_expected_result) { { :'1' => 201, :'2' => 202 } }

        context 'given an already opened stream as input' do
          let(:app1) { [255, 225, 0, endian_vals[:app1_body_two_blocks].size + 8] + "Exif\0\0".bytes + endian_vals[:app1_body_two_blocks] }
          let(:app0) { [255, 224, 0, 2] }
          let(:jpeg_soi) { [255, 216] }
          let(:read_tags) { exif.read_tags(stream, *specific_tags) }

          describe 'no specific tags given' do
            let(:specific_tags) { [] }

            describe 'exif section is not the first jpeg section' do
              let(:test_bytes) { jpeg_soi + app0 + app1 }
              it { expect(read_tags).to eq(all_tags_expected_result) }
            end

            describe 'exif section is the first jpeg section' do
              let(:test_bytes) { jpeg_soi + app1 }
              it { expect(read_tags).to eq(all_tags_expected_result) }
            end
          end

          describe 'one or more specific tags given' do
            describe 'specific tag not found' do
              let(:specific_tags) { 5 }
              let(:test_bytes) { jpeg_soi + app1 }
              it { expect(read_tags).to be_empty }
            end

            context 'first tag in exif data given as specific tag' do
              let(:specific_tags) { 1 }

              describe 'specific tag found' do
                let(:test_bytes) { jpeg_soi + app1 }
                it { expect(read_tags).to eq(:'1' => 201) }
              end

              describe 'does not read entire file if more tags exist' do
                let(:test_bytes) { jpeg_soi + app1 }

                it do
                  read_tags
                  expect(stream.pos).to be < stream.size
                end
              end
            end
          end
        end

        # The test file is big endian so only test in that scenario
        unless is_little_endian
          context 'when given a file path as input' do
            let(:pwd) { File.expand_path(File.dirname(__FILE__)) }
            let(:file_path) { File.join(pwd, 'test_files/test.jpg') }

            it do
              File.open(file_path, 'rb') do |f|
                expect(exif.read_tags(f)).to eq(all_tags_expected_result)
              end
            end
          end
        end
      end
    end
  end

  describe '#to_slong' do
    it { expect(exif.to_slong(2**32 - 1)).to eq(-1) }
  end

  describe '#read_header' do
    let(:read_header) { exif.read_header(stream) }

    describe 'with an intel (little endian) marker' do
      let(:test_bytes) { ['II'.bytes, [42, 0]].flatten }
      it { expect(read_header).to be true }
    end

    describe 'with a motorolla (big endian) marker' do
      let(:test_bytes) { ['MM'.bytes, [0, 42]].flatten }
      it { expect(read_header).to be false }
    end

    describe 'with an unrecognized endian type marker' do
      let(:test_bytes) { ['AA'.bytes, [0, 42]].flatten }
      it { expect { read_header }.to raise_error(RuntimeError) }
    end
  end

  describe '#exif_section?' do
    describe 'given a jpeg section' do
      let(:exif_section?) { exif.exif_section?(stream, section_marker) }

      describe 'whose marker is NOT an exif marker' do
        let(:section_marker) { [255, 226] }
        let(:test_bytes) { [] }
        it { expect(exif_section?).to be false }
      end

      describe 'whose marker is an exif marker' do
        let(:section_marker) { [255, 225] }

        describe 'whose body starts with the exif header' do
          let(:test_bytes) { "Exif\0\0".bytes }
          it { expect(exif_section?).to be true }
        end

        describe 'whose body does NOT start with the exif header' do
          let(:test_bytes) { 'OtherHeader'.bytes }
          it { expect(exif_section?).to be false }
        end
      end
    end
  end
end
