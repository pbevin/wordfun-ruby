//= require jquery.lightbox_me
//= require_self

$(function() {
  var thesaurusPreview = $('#thesaurus_preview');
  var thesaurusInput = $('#thesaurus');

  function parseTerm(term, callback) {
    var word, context, parts;
    if (term.match(/::/)) {
      parts = term.split('::');
      word = $.trim(parts[0]);
      context = $.trim(parts[1]);
    } else {
      word = term;
      context = null;
    }
    callback(word, context);
  }

  function showResults(type) {
    var text_input = $('#' + type);
    var path = '/words/' + type;

    return function() {
      var term = text_input.val();

      if (term !== '') {
        parseTerm(term, function(word, context) {

          $.get(path, { q: word, c: context }, function(result) {
            var words = result.words;
            var text = $("#result_text");
            var i;
            var word, entry;

            text.empty();
            for (i = 0; i < words.length; i++) {
              word = words[i];

              entry = $('<div class="entry">');
              entry.append($('<a>').
                attr("href", "http://www.thefreedictionary.com/" + encodeURIComponent(word.word)).
                attr("target", "wf_lookup").
                text(word.word));
              if (word.definition) {
                entry.append($("<dfn>").text(word.definition));
                entry.append($("<div class=\"fade\">"));
              }
              if (word.score) {
                entry.addClass("good");
              }
              text.append(entry);
            }

            $('#intro').hide();
            $('#results').show();
            $('#search_term').html(term);
          });
        });
      }
      return false;
    };
  }

  var currentlyShowing = {};
  var currentlyRequesting = {};

  function preview(type) {
    var text_input = $('#' + type);
    var preview = $('#' + type + "_preview");
    var path = '/preview/' + type;

    return function() {
      var term = text_input.val();
      if (term !== '') {
        parseTerm(term, function(word, context) {
          delay(function() {
            if (term === currentlyRequesting[type] || term === currentlyShowing[type] || text_input.val() !== term) return;
            currentlyRequesting[type] = term
            $.get(path, { q: word, c: context }, function(text) {
              if (text_input.val() === term) {
                preview.text(text).show();
                currentlyShowing[type] = term;
                currentlyRequesting[type] = null;
              }
            });
          });
        });
      } else {
        currentlyShowing[type] = "";
        preview.hide();
      }
      return false;
    };
  }

  function thesPreview() {
    var word = thesaurusInput.val();

    if (word === '') {
      thesaurusPreview.hide();
      currentlyShowing.thesaurus = "";
    } else {
      delay(function() {
        if (word === currentlyRequesting.thesaurus || word === currentlyShowing.thesaurus || thesaurusInput.val() !== word) return;
        currentlyRequesting.thesaurus = word;
        $.getJSON("/preview/thesaurus", { q: word }, function(result) {
          var matches;
          var list$ = $('<ul>');

          if (result.words.length === 0) {
            list$ = list$.append("<li>No matches.</li>");
          } else {
            result.words.forEach(function(w) {
              var len = w[0];
              var words = w[1];
              var group$ = $('<li>');
              group$.append(len + ": ");
              words.forEach(function(word, i) {
                var link =
                  $('<a href="javascript:void(0)"></a>')
                    .text(word)
                    .on('click', function() { thesaurusSearch(word) });
                if (i > 0) {
                  group$.append(", ")
                }
                group$.append(link);
              });
              list$.append(group$);
            });
          }
          thesaurusPreview.html(list$).show();
          currentlyShowing.thesaurus = word;
          currentlyRequesting.thesaurus = null;
        });
      });
    }
  }

  function thesaurusSearch(word) {
    thesaurusInput.val(word);
    thesPreview();
  }

  function thesResults(e) {
    e.preventDefault();
  }

  function delay(f) { setTimeout(f, 100); }

  $(document).on("click", "#result_text a", function(e) {
    var url = $(this).attr("href");
    e.preventDefault();
    $('#def').find("iframe").attr("src", url);
    $('#def').lightbox_me({
      centered: true
    });
  });

  $('#anform').submit(showResults('an')).keyup(preview('an'));
  $('#fwform').submit(showResults('fw')).keyup(preview('fw'));
  $('#crform').submit(showResults('cr')).keyup(preview('cr'));
  $('#thesform').submit(thesResults).keyup(thesPreview);
  $('#an').focus();
});
