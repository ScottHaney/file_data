# file_data [![Build Status](https://travis-ci.org/ScottHaney/file_data.svg?branch=master)]

Ruby library that reads Exif tag data from Jpeg files. More file data formats may be supported in the future.

Examples for getting Exif tags:

```ruby
exif = FileData::Exif.new

#All Exif tags from a file
hash = exif.read_tags("path_to_file")

#All Exif tags from a binary stream
io = StringIO.open("...")
hash = exif.read_tags(io)

#Only specific tag id numbers (see exif_tags.rb or the Exif spec)
image_width = 256
image_length = 257
hash = exif.read_tags("path_to_file", image_width, image_length)
```

Return Values:

Tag type TYPE_UNDEFINED: Array of bytes and boolean which is true if the bytes are little endian

Tag type that is not recognized: nil

Otherwise: The value as the most appropriate type