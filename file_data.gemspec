# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'file_data/version'

Gem::Specification.new do |spec|
  spec.name          = "file_data"
  spec.version       = FileData::VERSION
  spec.authors       = ["Scott"]
  spec.email         = [""]

  spec.summary       = %q{Provides apis for extracting common metadata out of files as well as low level apis for advanced metadata parsing. Currently exif (jpeg/jpg) is almost entirely supported and mpeg4 (mp4,m4v,moov...) has limited support}
  spec.description   = %q{Provides apis for extracting common metadata out of files as well as low level apis for advanced metadata parsing. Currently exif (jpeg/jpg) is almost entirely supported and mpeg4 (mp4,m4v,moov...) has limited support. For common metadata the FileInfo class provides methods names after the metadata items taking a filename. As an example, to get the origin date of a file you would call FileData::FileInfo.origin_date(filename). Advanced apis are provided via specific classes for each metadata type. For example, Exif for exif data and Mpeg4 for mpeg4 data. These can be used to improve the performance of gathering multiple metadata values from a file}
  spec.homepage      = "https://github.com/ScottHaney/file_data"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "fakefs", "~> 0.10"
  spec.add_development_dependency "deep-cover", "~> 0.6"
end
