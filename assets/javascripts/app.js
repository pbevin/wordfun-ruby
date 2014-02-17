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

  $('#anform').submit(handler('an')).keyup(preview('an'));
  $('#fwform').submit(handler('fw')).keyup(preview('fw'));
  $('#crform').submit(handler('cr')).keyup(preview('cr'));
  $('#an').focus();
});
