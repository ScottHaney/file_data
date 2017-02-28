file_data
=========

[![Build Status](https://travis-ci.org/ScottHaney/file_data.svg?branch=master)](https://travis-ci.org/ScottHaney/file_data)
[![Coverage Status](https://coveralls.io/repos/github/ScottHaney/file_data/badge.svg?branch=master)](https://coveralls.io/github/ScottHaney/file_data?branch=master)
[![Code Climate](https://codeclimate.com/github/ScottHaney/file_data/badges/gpa.svg)](https://codeclimate.com/github/ScottHaney/file_data)

Ruby library that reads Exif tag data from Jpeg files. More file data formats may be supported in the future.

Examples for getting Exif tags:

```ruby
# Get Exif data from a file path
File.open('...', 'rb') do |f|
  exif = FileData::Exif.from_stream(f)
  # Insert command here, should only use a single command...
end

# Command examples

# Get only the image Exif data
hash = exif.image_data_only

# Get only the thumbnail Exif data
hash = exif.thumbnail_data_only

# Get all data (image and thumbnail)
# Use result.image or result.thumbnail to get value hashes
result = exif.all_data

# Get only a single tag
# tag_id is the key from FileData::ExifTags.tag_groups and then the tag key in the value hash
# for example [34_665, 36_867] is tag :Exif_DateAndTime_DateTimeOriginal

# Image example
tag_value = exif.only_image_tag(tag_id)

# Thumbnail example
tag_value = exif.only_thumbnail_tag(tag_id)

# Complete example
File.open('...', 'rb') do |f|
  exif = FileData::Exif.from_stream(f)
  hash = exif.image_data_only
end


