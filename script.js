// Generated by CoffeeScript 1.6.2
(function() {
  var $, Canvas, context, init, log, updateCanvas;

  $ = jQuery;

  log = function(message) {
    if (typeof console === 'object') {
      return console.log(message);
    } else {
      return null;
    }
  };

  Canvas = null;

  context = null;

  init = function() {
    var draw, i, imageSources, images, imagesLoaded, src, _i, _len, _loaded;

    Canvas = document.getElementById('myCanvas');
    context = Canvas.getContext('2d');
    images = [];
    imageSources = ['images/im01.png', 'images/im02.png', 'images/im03.png', 'images/im04.png', 'images/im05.png', 'images/im06.png', 'images/im07.png', 'images/im10.png', 'images/im11.png', 'images/im12.png', 'images/im13.png', 'images/im14.png', 'images/im15.png', 'images/im16.png', 'images/im17.png', 'images/im20.png', 'images/im21.png', 'images/im22.png', 'images/im23.png', 'images/im24.png', 'images/im25.png', 'images/im26.png', 'images/im27.png', 'images/im28.png', 'images/im29.png', 'images/im30.png', 'images/im31.png', 'images/im32.png', 'images/im33.png', 'images/im34.png', 'images/im35.png'];
    /* Load the images in to memory
    */

    imagesLoaded = 0;
    _loaded = false;
    for (i = _i = 0, _len = imageSources.length; _i < _len; i = ++_i) {
      src = imageSources[i];
      images[i] = new Image();
      images[i].src = src;
      images[i].onload = function() {
        imagesLoaded++;
        if (imagesLoaded === imageSources.length) {
          draw();
          return log("loaded");
        }
      };
    }
    draw = function() {
      updateCanvas(images[0]);
    };
    $('.slider').slider({
      value: 0,
      min: 0,
      max: images.length,
      step: 1,
      animate: true,
      slide: function(event, ui) {
        var current_img, current_snap, forward_intv, loop_img, new_snap, reverse_intv, total_img;

        current_snap = $('.value').text();
        $('.old_value').html(current_snap);
        $('.value').html(ui.value);
        new_snap = $('.value').text();
        if (new_snap - current_snap > 1) {
          total_img = new_snap - current_snap;
          current_img = current_snap;
          loop_img = 1;
          forward_intv = setInterval(function() {
            current_img++;
            if (loop_img <= total_img) {
              updateCanvas(images[current_img]);
              console.log("Image " + current_img);
              return loop_img++;
            } else {
              return clearInterval(forward_intv);
            }
          }, 50);
        } else if (new_snap - current_snap < -1) {
          total_img = new_snap - current_snap;
          current_img = current_snap;
          loop_img = -1;
          reverse_intv = setInterval(function() {
            current_img--;
            if (loop_img >= total_img) {
              updateCanvas(images[current_img]);
              console.log("Image " + current_img);
              return loop_img--;
            } else {
              return clearInterval(reverse_intv);
            }
          }, 50);
        } else {
          updateCanvas(images[ui.value]);
        }
      }
    });
  };

  updateCanvas = function(ImgObj) {
    if (typeof ImgObj !== 'undefined') {
      context.drawImage(ImgObj, 0, 0, 500, 500);
    }
  };

  $(document).ready(function() {
    return init();
  });

}).call(this);
