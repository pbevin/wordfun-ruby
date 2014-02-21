$(function() {
  function showResults(type) {
    var text_input = $('#' + type);
    var path = '/words/' + type;
    return function() {
      var term = text_input.val();
      if (term !== '') {
        $.get(path, { q: term }, function(data) {
          $('#intro').hide();
          $('#results').show();
          $('#search_term').html("`" + term + "'");

          var words = data.split("\n");
          var i, text;

          if (words.length > 1000) {
            text = data.replace(/\n/g, "<br>\n");
          } else {
            text = "";
            for (i = 0; i < words.length; i++) {
              text += '<a class="def" href="javascript:void(0);">' + words[i] + "</a><br>\n";
            }
          }
          $('#result_text').html(text);
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
    var url = "http://en.wiktionary.org/wiki/" + encodeURIComponent(word) + "?printable=yes#English";

    $("#defn .title").text(word);
    $("#defn iframe").attr("src", url)
    $("#defn").show();
  });

  $('#anform').submit(showResults('an')).keyup(preview('an'));
  $('#fwform').submit(showResults('fw')).keyup(preview('fw'));
  $('#crform').submit(showResults('cr')).keyup(preview('cr'));
  $('#an').focus();
});
