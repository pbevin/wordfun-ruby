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

    def each
      @words.each
    end
  end
end
