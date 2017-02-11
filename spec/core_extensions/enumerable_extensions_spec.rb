require 'file_data/core_extensions/enumerable_extensions'

# Refinements local to this file only for testing
module Refinements
  refine Array do
    include EnumerableExtensions
  end
end

using Refinements

RSpec.describe EnumerableExtensions do
  describe '#condense' do
    context 'when a sequence of two sequences' do
      it 'concatenates the inner two sequences into a single sequence' do
        expect([[1, 2], [3, 4]].condense.to_a).to eq([1, 2, 3, 4])
      end
    end
  end
end
