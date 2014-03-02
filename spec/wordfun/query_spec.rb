require 'wordfun/query'

describe Wordfun::Query do
  let(:q) { Wordfun::Query.new }
  it "can get and set parameters" do
    q.command = "fw"
    q.word = "a.b."
    q.context = "platform"

    expect(q.command).to eq("fw")
    expect(q.word).to eq("a.b.")
    expect(q.context).to eq("platform")
  end

  it "can compute word lengths" do
    q.word = "....."
    expect(q.word_lengths).to eq("5")

    q.word = ".../..../....."
    expect(q.word_lengths).to eq("3,4,5")
  end

  it "can tell if it has a context" do
    q.context = nil
    expect(q.context?).to be_falsy

    q.context = "platform"
    expect(q.context?).to be_truthy

    q.context = ""
    expect(q.context?).to be_falsy
  end
end
