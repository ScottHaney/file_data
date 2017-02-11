# Adds the ability to concatenate enumerables with #condense
module EnumerableExtensions
  def condense
    Enumerator.new { |e| each { |seq| seq.each { |v| e << v } } }.lazy
  end
end
