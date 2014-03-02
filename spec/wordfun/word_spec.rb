require 'wordfun/word'

describe Wordfun::Word do
  let(:coffee) { Wordfun::Word.new("Coffee") }

  describe '#downcase' do
    it "gives the word in lower case" do
      coffee.downcase.should == "coffee"
    end
  end

  describe '#define' do
    it "gives a word with a definition" do
      coffee.define("Hot drink").
        definition.should == "Hot drink"
    end
  end

  describe '#to_api' do
    it "has the word as a key" do
      coffee.to_api.should == { word: "Coffee" }
    end

    it "may have a definition" do
      coffee.define("Hot drink").to_api.should == {
        word: "Coffee",
        definition: "Hot drink"
      }
    end
  end
  
end
