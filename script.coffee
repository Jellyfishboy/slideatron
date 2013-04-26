$ = jQuery
log = (message) ->
  if typeof(console) is 'object' then console.log(message) else return null

# Keep these as somewhat global
Canvas = null
context = null

init = ->
  Canvas = document.getElementById 'myCanvas'
  context = Canvas.getContext '2d'
  images = []
  
  # Image array - This will be written to the head by sitecore
  imageSources = [
    'images/im01.png'
    'images/im02.png'
    'images/im03.png'
    'images/im04.png'
    'images/im05.png'
    'images/im06.png'
    'images/im07.png'
    'images/im10.png'
    'images/im11.png'
    'images/im12.png'
    'images/im13.png'
    'images/im14.png'
    'images/im15.png'
    'images/im16.png'
    'images/im17.png'
    'images/im20.png'
    'images/im21.png'
    'images/im22.png'
    'images/im23.png'
    'images/im24.png'
    'images/im25.png'
    'images/im26.png'
    'images/im27.png'
    'images/im28.png'
    'images/im29.png'
    'images/im30.png'
    'images/im31.png'
    'images/im32.png'
    'images/im33.png'
    'images/im34.png'
    'images/im35.png'
  ]


  ### Load the images in to memory ###
  imagesLoaded = 0
  _loaded = false
  for src, i in imageSources
    images[i] = new Image()
    images[i].src = src
    images[i].onload = ->
      imagesLoaded++
      # TODO: Put a nicer preloader in here
      if imagesLoaded == imageSources.length
        draw()
        log "loaded"

  # Function is called once all images have been loaded in
  draw = ->
    updateCanvas(images[0])
    return

  # Make the slider
  $('.slider').slider({
    value: 0
    min: 0
    max: images.length
    step: 1
    animate: true
    slide: (event, ui) ->
      # on slide event...     
      #appends old value element with current snap
      current_snap = $('.value').text()
      $('.old_value').html current_snap
      $('.value').html ui.value
      new_snap = $('.value').text()
      #if slider is moved forwards
      if (new_snap-current_snap > 1)
        #total number of images to cycle through during transition
        total_img = new_snap-current_snap
        #current image before the animation begins
        current_img = current_snap
        #start the loop
        loop_img = 1
        #set intervl between each image iteration
        forward_intv = setInterval(->
          #increment the image array id
          current_img++
          #if current loop count is less or equal to total number of image to cycle through
          if loop_img <= total_img
            #update canvas with current image
            updateCanvas images[current_img]
            log "Image " + current_img
            #increment loop count
            loop_img++
          else
            clearInterval(forward_intv)
        , 50)
      #if slider is moved backwards
      else if (new_snap-current_snap < -1)
        total_img = new_snap-current_snap
        current_img = current_snap
        loop_img = -1
        reverse_intv = setInterval(->
          current_img--
          if loop_img >= total_img
            updateCanvas images[current_img]
            log "Image " + current_img
            loop_img--
          else 
            clearInterval(reverse_intv)
        , 50)
      #if slide value is only 1, execute a single image change
      else
        updateCanvas images[ui.value]
      return
    stop: (event, ui) ->
      # find all elements on the current frame and add a class
      $('.hedgehog-' + ui.value).addClass('active')
      $('svg.hedgehog-' + ui.value).attr("class", "hedgehog active hedgehog-" + ui.value)
      #for old IE
      $('.hedgehog-' + ui.value + " .rvml").show()
      # If using vml we have to be a bit more hardcore and target the rvml elements
      return
    start: (event, ui) ->
      $('#content .active').removeClass('active')
      $('svg.active').attr("class", "hedgehog hedgehog-" + ui.value)
      $('.hedgehog .rvml').hide()
      return
  })
     
  return

## function takes an image and prints it to the canvas
updateCanvas = (ImgObj) ->
  if typeof ImgObj isnt 'undefined'
    context.drawImage ImgObj, 0,0, 500, 500
  return

# these are test image arrays
# These could be automatically generated within sitecore
lines = [
  line1 = {
    frame: 14
    path: "M100,120L100,250L150,250"
  }
  line2 = {
    frame: 27
    path: "M250,450L200,400L200,350"
  }
]


drawLines = (lineArray) ->
  # make the paper for which to draw the lines on

  for lineData in lineArray
    # have to define an individual canvas for each set of lines as you can't apply classes to vml shapes
    paper = Raphael $(".lines")[0], 500, 500
    paper.canvas.style.position = "absolute"
    $(paper.canvas).attr("class", "hedgehog hedgehog-" + lineData.frame)
    line = paper.path lineData.path
  
  # after drawing the lines. Check if they're vml and make them invisible.
  # Need to target th child elements because IE is super super lame
  if Raphael.vml
    # find all the rvml elements made by Raphael and hide them
    $('.hedgehog .rvml').hide()

  return


$(window).load ->
  init()
  drawLines(lines)
  return
