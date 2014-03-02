//= require jquery.lightbox_me
//= require_self

$(function() {
  function showResults(type) {
    var text_input = $('#' + type);
    var path = '/words/' + type;

    return function() {
      var term = text_input.val();
      var context = $('#' + type + 'c').val();
      if (term !== '') {
        $.get(path, { q: term, c: context }, function(result) {
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
    var context = $('#' + type + 'c').val();
    var path = '/preview/' + type;
    return function() {
      var term = text_input.val();
      if (term !== '') {
        delay(function() {
          if (term === currentlyShowing || text_input.val() !== term) return;
          $.get(path, { q: term, c: context }, function(text) {
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
  $('#an').focus();
});
