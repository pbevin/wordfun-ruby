require 'wordfun/result'

describe Wordfun::Result do
  let(:result) { Wordfun::Result.new(words) }
  let(:words) { %w[ arts rats star tars tsar ] }

  describe '#count' do
    it "returns the number of words" do
      result.count.should == 5
    end
  end

  describe '#as_list' do
    it "returns the words separated by comma" do
      result.as_list.should == "arts, rats, star, tars, tsar"
    end
  end
  
  describe '#truncate' do
    it "takes the first n results and adds a ..." do
      result.truncate(2).as_list.should == "arts, rats, ..."
    end

    it "does not add ... if the list is not truncated" do
      result.truncate(5).as_list.should == "arts, rats, star, tars, tsar"
    end

    it "does not affect the count" do
      result.truncate(2).count.should == 5
    end
  end
  
end

