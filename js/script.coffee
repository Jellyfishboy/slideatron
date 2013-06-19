$ = jQuery

#####################################
#    Check if console exists (IE)   #
#####################################
log = (message) ->
  if typeof console is 'object' then console.log(message) else return null

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

#####################################
#             Variables             #
#####################################
Canvas = null
context = null
total_images = null
images = []
window.breakCounter = -1
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
# Setup slide frame object for current and previous frames when using the slider
window.slideFrame = new Object()
slideFrame.previous = 0
slideFrame.current = 0
slideFrame.swipe_previous = 0
slideFrame.swipe_current = 0

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
    total_images = imageSources.length

  # Function is called once all images have been loaded in
  draw = ->
    updateCanvas images[0]
    return

  #####################################
  #        Initiate the slider        #
  #####################################
  $('.slider').slider({
    value: 0
    min: 0
    max: images.length
    step: 1
    animate: true

    slide: (event, ui) ->
      # on slide event...
      # Sets the previous slide fram value before it updates the current slide frame with the slider ui value
      slideFrame.previous = slideFrame.current
      slideFrame.current = ui.value
      updateIndicators ui.value
      #if slider is moved forwards
      if slideFrame.current-slideFrame.previous > 1
        imageCycle slideFrame.current, slideFrame.previous, 1, "increment"
      #if slider is moved backwards
      else if slideFrame.current-slideFrame.previous < -1
        imageCycle slideFrame.current, slideFrame.previous, -1, "decrement"
      #if slide value is only 1, execute a single image change
      else
        updateCanvas images[ui.value]
      return

    stop: (event, ui) ->
      # Need to setup unique current and previous snap values as the initial values are recorded in real time when using the slide function above. This creates an inaccurate increment/decrement function. 
      slideFrame.swipe_previous = slideFrame.swipe_current
      slideFrame.swipe_current = ui.value
      for lineData in lineArray
        # Determines whether the next frame which the user slides to has originated from before a breakpoint and lands after a breakpoint, in order to calculate the new breakCounter value
        if ui.value > lineData.frame-1 and slideFrame.swipe_previous < lineData.frame
          breakCounter++
        else if ui.value < lineData.frame and slideFrame.swipe_previous > lineData.frame-1
          breakCounter--
      # Update the relevant elements
      updateElements ui.value
      return
    start: (event, ui) ->
      # Hide the relevant elements
      hideElements ui.value
  })       
  return

#####################################
#             Functions             #
#####################################

# Function to hide the redundant elements for the specified breakpoint
hideElements = (value) ->
  $('#content .active').removeClass 'active'
  # removeClass doesn't work on svgs, have to do it by hand
  $('svg.active').attr "class", "hedgehog hedgehog-" + value
  $('.hedgehog .rvml').hide()
  return

# Updates the elements for the specified breakpoint
updateElements = (value) ->
  # find all elements on the current frame and add a class
  $('.hedgehog-' + value).addClass 'active'
  $('svg.hedgehog-' + value).attr "class", "hedgehog active hedgehog-" + value
  #for old IE
  # If using vml we have to be a bit more hardcore and target the rvml elements
  $('.hedgehog-' + value + " .rvml").show()
  # Call to update the slider indicators
  updateIndicators value
  return

# Takes the passed in image object, and prints it to the canvas
updateCanvas = (ImgObj) ->
  if typeof ImgObj isnt 'undefined'
    context.drawImage ImgObj, 0,0, 500, 500
  return

# Draw the SVG lines
drawLines = (lineArray) ->
  # make the paper for which to draw the lines on
  for lineData in lineArray
    # have to define an individual canvas for each set of lines as you can't apply classes to vml shapes
    paper = Raphael $(".lines")[0], 500, 500
    paper.canvas.style.position = "absolute"
    $(paper.canvas).attr "class", "hedgehog hedgehog-" + lineData.frame
    line = paper.path lineData.path

    # Setting up indicator element to be generated for each breakpoint dynamically
    slider_width = $('.ui-slider').outerWidth()
    indicator_loc = slider_width/total_images*lineData.frame
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

# Cycle through images when you click along the slider
imageCycle = (current, previous, loop_img, operator) ->
  #total number of images to cycle through during transition
  total_img = current-previous
  #current image before the animation begins
  current_img = previous
  
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



# Attach google analytics trigger to any call to action buttons within the hedgehogs
CTA_buttons = ->
  $('.hedgehog button').click ->
    tracker_tag = $(@).attr 'data-tracking'
    SwoopGAData.send ["CTA", tracker_tag]

# Highlight indicator when the user lands on the relevant breakpoint
updateIndicators = (ui) ->
  if ($('.indicate').hasClass 'indicator-' + ui)
    $('.indicate').removeClass "indicate_selected"
    $('.indicator-' + ui).addClass "indicate_selected"
    SwoopGAData.send(["click", "breakpoint-"+ui])
  else
    $('.indicate').removeClass "indicate_selected"

# Position the CSS3 loading animation
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
nextBreakpoint = (lineArray) ->
  # Prevent the breakCounter variable counting up if there are not more items left in the 'lines' JSON object
  cap = breakCounter+1
  if cap < lineArray.length
    breakCounter++
    slideFrame.previous = slideFrame.current
    slideFrame.swipe_previous = slideFrame.swipe_current
    updateForwardSwipe lineArray, slideFrame.previous
  hideElements slideFrame.previous
  updateElements $('.slider').slider("value")

# Previous breakpoint (mobile/scroll only)
previousBreakpoint = (lineArray) -> 
  slideFrame.previous = slideFrame.current
  slideFrame.swipe_previous = slideFrame.swipe_current
  hideElements slideFrame.previous
  for lineData in lineArray   
    if breakCounter is -1
      slideFrame.current = 0
      slideFrame.swipe_current = 0
      imageCycle(0, slideFrame.previous, -1, "decrement")
      $('.slider').slider "value", 0  
    else if parseInt(slideFrame.current) is lineData.frame and breakCounter is 0
      breakCounter--
      slideFrame.current = 0
      slideFrame.swipe_current = 0
      imageCycle(0, slideFrame.previous, -1, "decrement")
      $('.slider').slider "value", 0  
    # Required to use slideFrame.swipe_current to prevent secondary evaluation
    else if parseInt(slideFrame.swipe_current) is lineData.frame
      breakCounter--
      updateBackwardSwipe lineArray, slideFrame.previous
    else if breakCounter is lineArray.length-1
      updateBackwardSwipe lineArray, slideFrame.previous
    else
  # The slideFrame.current variable is updated with the new lineData.frame value before it reaches the second iteration of the if statement. This results in the second if iteration to evaluate a second argument, as detailed above, because the slideFrame object is global. By uisng the slideFrame.swipe_current value and only updating the value after the for loop, enables us to evaluate only one argument in the statement.
  # Also check if breakcounter is less than 0, set swipe_current value to 0 (frame)
  if breakCounter is -1 
    slideFrame.swipe_current = 0
  else
    slideFrame.swipe_current = lineArray[breakCounter].frame
  updateElements slideFrame.current

updateBackwardSwipe = (lineArray, previous) ->
  slideFrame.current = lineArray[breakCounter].frame
  imageCycle slideFrame.current, previous, -1, "decrement"
  $('.slider').slider "value", slideFrame.current

updateForwardSwipe = (lineArray, previous) ->
  slideFrame.current = lineArray[breakCounter].frame
  slideFrame.swipe_current = lineArray[breakCounter].frame
  imageCycle slideFrame.current, previous, 1, "increment"
  $('.slider').slider "value", slideFrame.current

# Calculate when a value lies between two specified values
between = (x, min, max) ->
  return x >= min and x <= max

#####################################
#   Google analytics integration    #
#####################################
class SwoopAnalyticsData

  # Assemble the constructor
  constructor: (@enabled) ->
    @send()

  # Default the event to 'snap'
  event: "snap"

  # Build the array to be pushed to the _gaq object
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

  # Push the array built above into the _gaq object
  send: (breakpoints_array) ->
    if @enabled 
      log breakpoints_array
      _gaq.push(@build(breakpoints_array))
    return

#####################################
#         Mousewheel binding        #
#####################################
$("#content").bind "mousewheel DOMMouseScroll", (e) ->

  delta = 0
  sliderElement = $(this).find '.slider'
  oe = e.originalEvent # for jQuery >=1.7
  value = sliderElement.slider 'value'
  # start the slide
  hideElements value

  delta = -oe.wheelDelta  if oe.wheelDelta
  delta = oe.detail * 40  if oe.detail
  value = if delta > 0 then value + 1 else value - 1
  

  result = sliderElement.slider("option", "slide").call(sliderElement, e,
    value: value
  )
  sliderElement.slider "value", value  if result isnt false
  updateElements value

  false