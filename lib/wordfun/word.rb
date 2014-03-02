class Wordfun
  class Word
    def initialize(word)
      @word = word
    end

    def downcase
      @word.downcase
    end

    def to_api
      { word: @word }
    end

    def define(definition)
      WordWithDefinition.new(@word, definition)
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
