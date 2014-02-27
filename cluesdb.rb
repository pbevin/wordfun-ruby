require 'mysql2'

client = Mysql2::Client.new(
  host: "localhost",
  database: "wordfun",
  username: "pete",
  encoding: "utf8"
)


File.open("clues", "r") do |f|
  client.query("DROP TABLE clues");
  client.query("create table clues (id int primary key auto_increment, word varchar(255), level integer, clue text, fulltext(clue), key byword (word)) Engine=MyISAM");
  f.each_line do |line|
    # puts line
    # p line.bytes.to_a

    line.chomp!
    begin
      line.force_encoding("WINDOWS-1252").encode("UTF-8")
    rescue Encoding::UndefinedConversionError
      puts line
      line = '# unconvertible'
    end
    next if line =~ /^#/

    word, level, _, _, clue = line.split(/\s+/, 5)
    word.strip!
    level.strip!
    clue.strip!

    q = "INSERT INTO clues (word, level, clue) VALUES ('#{word}', #{level}, '#{client.escape(clue)}')"
    client.query(q)
  end
end
