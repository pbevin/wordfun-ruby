$(function() {

  function showResults(type) {
    var text_input = $('#' + type);
    var path = '/words/' + type;
    return function() {
      var term = text_input.val();
      if (term !== '') {
        $.get(path, { q: term }, function(result) {
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
            if (word.defn) {
              entry.append($("<dfn>").text(word.defn));
              entry.append($("<div class=\"fade\">"));
            }
            text.append(entry);
          }

          $('#intro').hide();
          $('#results').show();
          $('#search_term').html("`" + term + "'");
        });
      }
      return false;
    };
  }

  function preview(type) {
    var currentlyShowing;
    var text_input = $('#' + type);
    var preview = $('#' + type + "_preview");
    var path = '/preview/' + type;
    return function() {
      var term = text_input.val();
      if (term !== '') {
        delay(function() {
          if (term === currentlyShowing || text_input.val() !== term) return;
          $.get(path, { q: term }, function(text) {
            if (text_input.val() === term) {
              preview.text(text).show();
              currentlyShowing = term;
            }
          });
        });
      } else {
        currentlyShowing = "";
        preview.hide();
      }
      return false;
    };
  }

  function delay(f) { setTimeout(f, 100); }

  $(document).on("click", ".def", function() {
    var word = $(this).text();
    //var url = "http://en.wiktionary.org/wiki/" + encodeURIComponent(word) + "?printable=yes#English";
    var url = "http://en.wiktionary.org/wiki/" + encodeURIComponent(word) + "#English";

    document.location = url;
    // $("#defn .title").text(word);
    // $("#defn iframe").attr("src", url)
    // $("#defn").show();
  });

  $('#anform').submit(showResults('an')).keyup(preview('an'));
  $('#fwform').submit(showResults('fw')).keyup(preview('fw'));
  $('#crform').submit(showResults('cr')).keyup(preview('cr'));
  $('#an').focus();
});
