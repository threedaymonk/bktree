require 'text/levenshtein'

module BK
  class LevenshteinDistancer
    def call(a, b)
      ::Text::Levenshtein.distance(a, b)
    end
  end
end
