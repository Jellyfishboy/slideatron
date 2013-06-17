$ = jQuery
log = (message) ->
  if typeof console is 'object' then console.log(message) else return null
###
# Lets start this up
###
$(document).ready ->
  # Set google analytics object
  gaEnabled = if typeof _gaq is 'object' then true else false
  window.SwoopGAData = new SwoopAnalyticsData gaEnabled
  return

$(window).load ->
  init(lines)
  drawLines(lines)
  positionLoader()
  CTA_buttons()
  $('.next').click ->
    nextBreakpoint(lines)
  $('.prev').click ->
    previousBreakpoint(lines)
  return

# Keep these as somewhat global
Canvas = null
context = null
totalimages = null
previous_snap = null
images = []
window.breakCounter = -1
window.lines = [
  line1 = {
    frame: 14
    path: "M100,120L100,250L150,250"
  }
  line2 = {
    frame: 27
    path: "M250,450L200,400L200,350"
  }
]
window.previous_snap = undefined
window.current_snap = undefined

class SwoopAnalyticsData

  constructor: (@enabled) ->
    @send()

  event: "snap"

  build: (breakpoints_array) ->
    if breakpoints_array isnt undefined
      @identifier = breakpoints_array[1]
      if breakpoints_array[0] isnt "CTA"
        @event = "click"       
        @category = 'swoop-breakpoints'
      else
        @event = "CTA"
        @category = 'swoop-call-to-action'
        
    return ['_trackEvent', @category, @event, @identifier]


  send: (breakpoints_array) ->
    if @enabled
      log breakpoints_array
      _gaq.push(@build(breakpoints_array))
    return

init = (lineArray) ->
  Canvas = document.getElementById 'myCanvas'
  context = Canvas.getContext '2d'
  
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


  # Load the images in to memory
  imagesLoaded = 0
  _loaded = false
  for src, i in imageSources
    images[i] = new Image()
    images[i].src = src
    images[i].onload = ->
      imagesLoaded++
      if imagesLoaded == imageSources.length
        $('#loader_wrapper').fadeTo "normal", 0
        draw()
        log "COMPLETE: Image sources"
    totalimages = imageSources.length

  # Function is called once all images have been loaded in
  draw = ->
    updateCanvas images[0]
    return

  ### 
    Make the slider
  ###
  $('.slider').slider({
    value: 0
    min: 0
    max: images.length
    step: 1
    animate: true

    create: (event, ui) ->
      previous_snap = $('.value').text()
      $('.old_value').html previous_snap
      $('.value').html ui.value
      current_snap = $('.value').text()

    slide: (event, ui) ->
      # on slide event...     
      #appends old value element with current snap
      previous_snap = $('.value').text()
      $('.old_value').html previous_snap
      $('.value').html ui.value
      current_snap = $('.value').text()
      updateIndicators(ui.value)
      #if slider is moved forwards
      if (current_snap-previous_snap > 1)
        imageCycle(current_snap, previous_snap, 1, "increment")
        for lineData in lineArray
          if ui.value >= lineData.frame and previous_snap <= lineData.frame
            breakCounter++
            log "break++"
      #if slider is moved backwards
      else if (current_snap-previous_snap < -1)
        imageCycle(current_snap, previous_snap, -1, "decrement")
      #if slide value is only 1, execute a single image change
        for lineData in lineArray
          if ui.value <= lineData.frame and previous_snap >= lineData.frame
            breakCounter--
            log "break--"
      else
        updateCanvas images[ui.value]
      return
    #
    change: (event, ui) ->
      # Call to update the slider indicators
      previous_snap = $('.value').text()
      $('.old_value').html previous_snap
      $('.value').html ui.value
      current_snap = $('.value').text()
      updateIndicators(ui.value)
      #if slider is moved forwards
      if (current_snap-previous_snap > 1)
        for lineData in lineArray
          if ui.value >= lineData.frame and previous_snap <= lineData.frame
            breakCounter++
            log "break++"
      #if slider is moved backwards
      else if (current_snap-previous_snap < -1)
      #if slide value is only 1, execute a single image change
        for lineData in lineArray
          if ui.value <= lineData.frame and previous_snap >= lineData.frame
            breakCounter--
            log "break--"
      return



    stop: (event, ui) ->
      slideStop(ui.value)
      # Call to update the slider indicators
      updateIndicators(ui.value)
      # # Uses the passed in lineArray and loops through each of the frame attributes in the line object
      # for lineData in lineArray
      #   # Checks if the current slider value is one before any frame attribute in the array
      #   lesser_frame = parseInt lineData.frame-1
      #   greater_frame = parseInt lineData.frame+1
      #   val = parseInt $('.old_value').text()
      #   # If slider value before the action was initiated is between greater and less frame object, then ignore the snapping functionality
      #   unless between(val, lesser_frame, greater_frame)
      #     if between(ui.value, lesser_frame, lineData.frame) 
      #       ui.value = snappingBreakingpoints(ui.value, lineData.frame, lesser_frame)
      #     # Else checks if the current slider value is one after any frame attribute in the array
      #     else if between(ui.value, lineData.frame, greater_frame)
      #       ui.value = snappingBreakingpoints(ui.value, lineData.frame, lesser_frame)
      return
    start: (event, ui) ->
      slideStart(ui.value)
      return
  })       
  return

slideStart = (value) ->
  $('#content .active').removeClass('active')
  # removeClass doesn't work on svgs, have to do it by hand
  $('svg.active').attr("class", "hedgehog hedgehog-" + value)
  $('.hedgehog .rvml').hide()
  return

slideStop = (value) ->
  # find all elements on the current frame and add a class
  $('.hedgehog-' + value).addClass('active')
  $('svg.hedgehog-' + value).attr("class", "hedgehog active hedgehog-" + value)
  #for old IE
  # If using vml we have to be a bit more hardcore and target the rvml elements
  $('.hedgehog-' + value + " .rvml").show()
  return

# function takes an image and prints it to the canvas
updateCanvas = (ImgObj) ->
  if typeof ImgObj isnt 'undefined'
    context.drawImage ImgObj, 0,0, 500, 500
  return

drawLines = (lineArray) ->
  # make the paper for which to draw the lines on

  for lineData in lineArray
    # have to define an individual canvas for each set of lines as you can't apply classes to vml shapes
    paper = Raphael $(".lines")[0], 500, 500
    paper.canvas.style.position = "absolute"
    $(paper.canvas).attr "class", "hedgehog hedgehog-" + lineData.frame
    line = paper.path lineData.path

    # Setting up indicator element to be generated for each snap point dynamically
    slider_width = $('.ui-slider').outerWidth()
    indicator_loc = slider_width/totalimages*lineData.frame
    # compensate for the size of the dot
    indicator_pos = indicator_loc-6
    indicator = "<span class='indicate indicator-" + lineData.frame + "'></span>"
    $('.ui-slider').append indicator
    $('.indicator-' + lineData.frame).css "left", indicator_pos
  
  # after drawing the lines. Check if they're vml and make them invisible.
  # Need to target th child elements because IE is super super lame
  if Raphael.vml
    # find all the rvml elements made by Raphael and hide them
    $('.hedgehog .rvml').hide()

  return

###
#  Mousewheel bindin'
###
$("#content").bind "mousewheel DOMMouseScroll", (e) ->

  delta = 0
  sliderElement = $(this).find '.slider'
  oe = e.originalEvent # for jQuery >=1.7
  value = sliderElement.slider("value")
  # start the slide
  slideStart(value)

  delta = -oe.wheelDelta  if oe.wheelDelta
  delta = oe.detail * 40  if oe.detail
  value = if delta > 0 then value + 1 else value - 1
  

  result = sliderElement.slider("option", "slide").call(sliderElement, e,
    value: value
  )
  sliderElement.slider "value", value  if result isnt false
  slideStop(value)

  false


# Cycle through images when you click along the slider
imageCycle = (current_snap, previous_snap, loop_img, operator) ->
  #total number of images to cycle through during transition
  total_img = current_snap-previous_snap
  #current image before the animation begins
  current_img = previous_snap
  
  if operator is "increment"
    #set intervl between each image iteration
    forward_intv = setInterval(->
      current_img++
      #if current loop count is less or equal to total number of image to cycle through
      if loop_img <= total_img
        #update canvas with current image
        updateCanvas images[current_img]
        #increment loop count
        loop_img++
      else
        clearInterval(forward_intv)
    , 50)
  else 
    #set intervl between each image iteration
    reverse_intv = setInterval(->
      current_img--
      #if current loop count is more or equal to total number of image to cycle through
      if loop_img >= total_img
        #update canvas with current image
        updateCanvas images[current_img]
        #decrement loop count
        loop_img--
      else
        clearInterval(reverse_intv)
    , 50)

# Update values upon snapping
# snappingBreakingpoints = (ui, frame_value, parameter) ->
#   $('.slider').slider "value", frame_value
#   $('.old_value').html parameter
#   $('.value').html frame_value
#   ui = frame_value
#   return ui
CTA_buttons = ->
  $('.hedgehog button').click ->
    tracker_tag = $(@).attr 'data-tracking'
    SwoopGAData.send(["CTA", tracker_tag])

# highlighting indicators logic
updateIndicators = (ui) ->
  if ($('.indicate').hasClass 'indicator-' + ui)
    $('.indicate').removeClass "indicate_selected"
    $('.indicator-' + ui).addClass "indicate_selected"
    SwoopGAData.send(["click", "breakpoint-"+ui])
  else
    $('.indicate').removeClass "indicate_selected"

positionLoader = ->
  $loader = $('#loader_wrapper')
  content_height = $('#content').height()
  content_width = $('#content').width()
  loader_width = $loader.width()
  loader_height = $loader.height()
  # Set the top position of the loader
  loader_top = (content_height-loader_height)/2
  $loader.css 'top', loader_top
  # Set the left position of the loader
  loader_left = (content_width-loader_width)/2
  $loader.css 'left', loader_left

# Next breakpoint (mobile/scroll only)
nextBreakpoint = (linesArray) ->
  breakCounter++
  log breakCounter
  previous_snap = $('.value').text()
  $('.old_value').html previous_snap
  current_snap = linesArray[breakCounter].frame
  $('.value').html current_snap
  imageCycle(current_snap, previous_snap, 1, "increment")
  $('.slider').slider "value", current_snap

# Previous breakpoint (mobile/scroll only)
previousBreakpoint = (linesArray) -> 
  previous_snap = $('.value').text()
  $('.old_value').html previous_snap
  if breakCounter is 0 
    $('.value').html "0"
    imageCycle(0, previous_snap, -1, "decrement")
    $('.slider').slider "value", 0
    breakCounter--
  else
    breakCounter--
    log breakCounter
    current_snap = linesArray[breakCounter].frame
    $('.value').html current_snap
    imageCycle(current_snap, previous_snap, -1, "decrement")
    $('.slider').slider "value", current_snap

# Helper function
between = (x, min, max) ->
  return x >= min and x <= max
