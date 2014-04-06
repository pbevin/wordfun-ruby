require 'lingua/stemmer'
require 'wordnet'
require 'mysql2'
require 'set'

client = Mysql2::Client.new(
  host: "localhost",
  database: "wordfun",
  username: "pete",
  encoding: "utf8"
)

$count = 0

def unaccent(word)
  word.
    gsub(/[ß]/, 'ss').
    gsub(/[ü]/, 'u').
    gsub(/[Ü]/, 'U').
    gsub(/[ö]/, 'o').
    gsub(/[Ö]/, 'O').
    gsub(/[ä]/, 'a').
    gsub(/[Ä]/, 'A').
    gsub(/[àáâãå]/, 'a').
    gsub(/[ÀÁÂÃÅ]/, 'A').
    gsub(/[Ç]/, 'C').
    gsub(/[ç]/, 'c').
    gsub(/[ÈÉÊË]/, 'E').
    gsub(/[èéêë]/, 'e').
    gsub(/[ÌÎÏ]/, 'I').
    gsub(/[ìîï]/, 'i').
    gsub(/[Ñ]/, 'N').
    gsub(/[ñ]/, 'n').
    gsub(/[ÒÓÔØ]/, 'O').
    gsub(/[òóôø]/, 'o').
    gsub(/[ÙÚÛÜ]/, 'U').
    gsub(/[ùúûü]/, 'u')
end

def find_word(client, letters)
  rows = client.query("SELECT id FROM words WHERE letters = '#{client.escape(letters)}'")

  id = nil
  rows.each do |row|
    id = row["id"]
  end

  id
end

def create_word(client, word, level=nil, definition=nil)
  letters = unaccent(word).downcase.gsub(/[^a-z]/, '')
  letters_rev = letters.reverse
  letters_an  = letters.split("").sort.join
  q = "INSERT IGNORE INTO words (word, letters, length, letters_reversed, letters_sorted) VALUES ('#{client.escape(word)}', '#{client.escape(letters)}', #{letters.length}, '#{client.escape(letters_rev)}', '#{client.escape(letters_an)}')"
  client.query(q)

  id = nil
  if client.affected_rows > 0
    $last = letters
    $last_id = id = client.last_id
    $count += 1
    puts q if $count % 1000 == 0
  elsif letters == $last
    id = $last_id
  end

  if definition
    id ||= find_word(client, letters)
    if id
      qq = "INSERT INTO definitions (word_id, level, definition) VALUES (#{id}, #{level}, '#{client.escape(definition)}')"
      client.query(qq)
    else
      puts "Oops, couldn't find #{letters}"
    end
  end
  # id = client.last_id

#   if clue
#     client
#   end
end

client.query("DROP TABLE IF EXISTS words");
client.query("create table words (id int primary key auto_increment, word varchar(255), length int, letters varchar(255), letters_reversed varchar(255), letters_sorted varchar(255), letters_crypto varchar(255), unique key byletters (letters), key bylettersrev(letters_reversed), key an(letters_sorted), key cr (letters_crypto), key len (length)) Engine=InnoDB CHARACTER SET = utf8");

client.query("DROP TABLE IF EXISTS definitions");
client.query("create table definitions (id int primary key auto_increment, word_id int references words(id), level int, definition text, fulltext(definition), key word (word_id)) Engine=InnoDB CHARACTER SET = utf8");

lex = WordNet::Lexicon.new
stemmer = Lingua::Stemmer.new(lang: "en")

File.open("anadict", "r") do |f|
  f.each_line do |line|
    line.chomp!
    begin
      line = line.force_encoding("WINDOWS-1252").encode("UTF-8")
    rescue Encoding::UndefinedConversionError
      puts line
      line = '# unconvertible'
    end
    next if line =~ /^#/
    word = line

    begin
      if entry = lex[word.downcase] || lex[stemmer.stem(word.downcase)]
        definition = entry.definition
      else
        definition = nil
      end
    rescue ArgumentError
      definition = nil
    end
    create_word(client, line, 0, definition)
  end
end

File.open("clues", "r") do |f|
  f.each_line do |line|
    line.chomp!
    begin
      line = line.force_encoding("WINDOWS-1252").encode("UTF-8")
    rescue Encoding::UndefinedConversionError
      puts line
      line = '# unconvertible'
    end
    next if line =~ /^#/ || line =~ /__/

    word, level, _, _, clue = line.split(/\s+/, 5)
    word.strip!
    level.strip!
    clue.strip!

    id = create_word(client, word.downcase, level, clue)
  end
end
