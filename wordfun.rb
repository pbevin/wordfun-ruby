require 'sinatra/base'
require 'haml'
require 'shellwords'

class Wordfun < Sinatra::Base
  enable :inline_templates

  get '/' do
    haml :index
  end

  get '/words/an' do
    cmd('an', params[:q])
  end

  get '/words/fw' do
    cmd('fw', params[:q])
  end

  get '/words/cr' do
    cmd('fw -c', params[:q])
  end

  get '/preview/an' do
    preview('an', params[:q])
  end

  get '/preview/fw' do
    preview('fw', params[:q])
  end

  get '/preview/cr' do
    preview('fw -c', params[:q])
  end

  private

  def cmd(name, query)
    query = query.downcase.gsub(" ", "").gsub("…", "...")
    cmd = "#{name} #{Shellwords.escape(query)}"

    `#{cmd}`.force_encoding("WINDOWS-1252").encode("UTF-8")
  end

  def preview(name, query)
    words = cmd(name, query).lines
    wc = words.count
    if wc > 10
      words = words.take(10) + ["..."]
    end
    words.map!(&:strip)
    pluralize(wc, "word") + " (#{words.join(", ")})"
  end

  def pluralize(n, noun)
    if n.to_i == 1
      "1 #{noun}"
    else
      "#{n} #{noun}s"
    end
  end
end

__END__

@@ index

%html
  %head
    %title Crossword Solver
    :css
      body { background: #ffffff; font-family: Arial, Helvetica, sans-serif}
      P.warning { font: italic small Verdana, Arial, Helvetica, sans-serif; color: #3366FF}
      h1 { font: 24pt sans-serif }
      h2 { font: 16pt sans-serif; font-weight: bold; color: red }
      #result_text {  font-family: "Courier New", Courier, mono}
      .preview { color: #f00; font-size: 12px; font-weight: bold; }
      .hidden { display: none; }

  %body
    #results.hidden
      %h1
        Results for
        %span#search_term
      #result_text
    #intro
      %h1 Crossword Solver

      %p I enjoy crosswords, and wrote these tools to help me.  There are well over a quarter of a million words and phrases in the dictionary, thanks to <a href="http://www.crosswordman.com/">Ross Beresford</a>'s UKACD dictionary and a huge list of phrases from Ross Withey.

      %blockquote
        %p.warning
          NB. If you're trying to find anagrams for someone's name, you're in the wrong place: see <a href="http://www.anagramgenius.com/">http://www.anagramgenius.com/</a>

    %hr
    %h2 Find an Anagram
    %p Type in a word or series of words here to get valid words and phrases from the dictionary.
    %form#anform
      %input#an{type: "text", name: "an", autocorrect: "off", autocapitalize: "off", tabindex: 1}
      %input{type: "Submit", value: "Anagram"}
      #an_preview.preview

    %hr
    %h2 Complete a Word or Phrase
    %p
      Type in what you have, with dots for the missing letters (e.g., <code>h.r...i.m</code>)
      to get matching words and phrases from the dictionary.  Don't type spaces between words.
      You can match word boundaries with forward slashes, like this: <code>h.r./...l../e.g</code>
    %form#fwform
      %input#fw{type: "text", name: "fw", autocorrect: "off", autocapitalize: "off", tabindex: 2}
      %input{type: "Submit", value: "Find Word/Phrase"}
      #fw_preview.preview

    %hr
    %h2 Solve a cryptogram
    %p Enter a word from a cryptogram, e.g., <code>opgxcxbgxs</code> to see words that match it.
    %form#crform
      %input#cr{type: "text", name: "cr", autocorrect: "off", autocapitalize: "off", tabindex: 3}
      %input{type: "Submit", value: "Cryptogram"}
      #cr_preview.preview

    %hr
    %address
      <a href="http://www.petebevin.com/">Pete Bevin</a>, <a href="mailto:pete@petebevin.com">pete@petebevin.com</a>.

    %script{src: "http://code.jquery.com/jquery-1.10.1.min.js", type: "text/javascript"}

  :javascript
    $(function() {
      function handler(type) {
        var text_input = $('#' + type);
        var path = '/words/' + type;
        return function() {
          var term = text_input.val();
          if (term !== '') {
            $.get(path, { q: term }, function(data) {
              $('#intro').hide();
              $('#results').show();
              $('#search_term').html("`" + term + "'");
              $('#result_text').html(data.replace(/\n/g, "<br>\n"));
            });
          }
          return false;
        };
      }

      function preview(type) {
        var text_input = $('#' + type);
        var preview = $('#' + type + "_preview");
        var path = '/preview/' + type;
        return function() {
          var term = text_input.val();
          if (term !== '') {
            $.get(path, { q: term }, function(text) {
              preview.text(text);
            });
          }
          return false;
        };
      }

      $('#anform').submit(handler('an')).keyup(preview('an'));
      $('#fwform').submit(handler('fw')).keyup(preview('fw'));
      $('#crform').submit(handler('cr')).keyup(preview('cr'));
      $('#an').focus();
    });
