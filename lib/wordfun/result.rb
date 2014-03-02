require 'wordfun/word'

class Wordfun
  class Result
    attr_reader :count

    def initialize(words)
      @words = words
      @count = words.count
    end

    def as_list
      @words.join(", ")
    end

    def truncate(n)
      if @count > n
        @words = @words.take(n) + ["..."]
      end
      self
    end

    def each(&block)
      @words.each(&block).map { |word| Wordfun::Word.new(word) }.to_enum
    end
  end
end
