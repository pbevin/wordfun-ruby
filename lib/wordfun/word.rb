class Wordfun
  class Word
    def initialize(word)
      @word = word
    end

    def downcase
      @word.downcase
    end

    def to_api
      { word: @word, score: score }
    end

    def define(definition)
      WordWithDefinition.new(@word, definition)
    end

    def canonical
      @word.upcase.gsub(/[^A-Z]/, '')
    end

    def score
      @score || 0
    end

    def definition
      ""
    end

    def score=(score)
      @score = score
    end
  end

  class WordWithDefinition < Word
    attr_reader :definition

    def initialize(word, definition)
      super(word)
      @definition = definition
    end

    def to_api
      super.merge(definition: definition)
    end
  end
end
