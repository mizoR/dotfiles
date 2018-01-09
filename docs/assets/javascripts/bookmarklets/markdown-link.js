/* name: Markdown link */

(function () {
    var link_to = function (text, url) {
      var t = text.replace(/([\[\]])/g,'\\$1');

      return '[' + t + ']' + '(' + url + ')';
    };

    var url = location.href;

    var text = document.title;

    prompt('Created', link_to(text, url));
  }
)();
