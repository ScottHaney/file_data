# Operations common to all files
class File
  class << self
    attr_reader :info_maps
  end

  @info_maps = {}  

  def self.creation_date(filename)
    reader_class(filename).send("creation_date", filename)
  end

  def self.reader_class(filename)
    info_maps[File.extname(filename).downcase]
  end
end
