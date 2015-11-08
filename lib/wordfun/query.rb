class Wordfun
  class Query
    attr_accessor :command, :word, :context

    def initialize(command=nil, word=nil, context=nil)
      @command = command
      @word = word
      @context = context
    end

    def self.from_web_params(params)
      self.new(params[:cmd], params[:q], params[:c])
    end

    def word=(word)
      @word = word.downcase.gsub(" ", "").gsub("…", "...").gsub("?", ".")
    end

    def word_lengths
      word.split("/").map(&:length).join(",")
    end

    def context?
      @context != nil && !@context.empty?
    end

    def word_with_lengths
      "#{@word} (#{word_lengths})"
    end
  end
end
