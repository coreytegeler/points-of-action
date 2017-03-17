// Generated by CoffeeScript 1.10.0
(function() {
  $(function() {
    var $body, $window;
    $window = $(window);
    $body = $('body');
    return $body.on('click touchend', '.band', toggleFloat);
  });

  window.toggleFloat = function(aside, dur) {
    var $aside, $band;
    if ($(aside).is('aside')) {
      $aside = $(aside);
      $band = $aside.find('.band');
    } else {
      $band = $(this);
      $aside = $band.parents('aside');
    }
    return $aside.toggleClass('open');
  };

}).call(this);
