giftiqueform = data:
  user: null
  occasion: null
  relationship: null
  recipient: "Recipient"
  location: null
  fooddrink: null
  activity: null
  hobby: null
  pricerange: "0-9999"

$('document').ready ->
  
  #Try to load previously entered info
  #"slow";
  slides = ->
    $slider.find $slide
  buttons = ->
    $(".giftique-slider-links").find ".slidelink"
  if localStorage.giftiquedata
    for id of giftiqueform.data
      if localStorage[id]
        giftiqueform.data[id] = localStorage[id]
        $("#" + id).val localStorage[id]
  $slider = $(".giftique-slider-frame")
  $slide = $(".giftique-slider")
  $active_slide = 0
  $slide_width = "850px"
  $easing = "easeOutCubic"
  $transition_speed = 400
  slides().first().addClass "active"
  slides().first().css left: "0px"
  slides().first().show()
  giftiqueform.changeto = (ind) ->
    if ind is $active_slide
      slides().eq(ind).effect "shake"
    else
      ind = $active_slide + 1  unless ind? #allows changeto() to increment slide
      ind = $active_slide - 1  if ind is -1 #allows changeto(-1) to decrement slide
      slides().eq($active_slide).removeClass "active"
      buttons().eq($active_slide).removeClass "current"
      slides().eq(ind).addClass "active"
      buttons().eq(ind).addClass "current"
      slides().eq(ind).show()
      slides().eq($active_slide).animate
        left: ((if $active_slide < ind then "-=" else "+=")) + $slide_width
      ,
        duration: $transition_speed
        complete: ($active_slide) ->
          slides().eq($active_slide).hide()

        easing: $easing

      slides().eq(ind).css left: ((if $active_slide < ind then "" else "-")) + $slide_width
      slides().eq(ind).animate
        left: ((if $active_slide < ind then "-=" else "+=")) + $slide_width
      ,
        duration: $transition_speed
        easing: $easing

      $active_slide = ind

  
  #process form changes on continue
  giftiqueform.cont = ->
    giftiqueform.getinput()
    giftiqueform.changeto()

  
  #process form changes on back
  giftiqueform.back = ->
    giftiqueform.getinput()
    giftiqueform.changeto -1

  giftiqueform.finish = ->
    giftiqueform.getinput()
    ajax_list = Array()
    ids = ["location", "fooddrink", "activity", "hobby"]
    i = 0

    while i < ids.length
      $("#" + ids[i] + "-results").slideDown()
      if giftiqueform.data[ids[i]]
        ajax_list.push
          name: ids[i]
          val: giftiqueform.data[ids[i]]

      i++
    giftiqueform.etsysearch ajax_list

  giftiqueform.getinput = ->
    
    #grab input from all locations
    for id of giftiqueform.data
      if $("#" + id).val()
        giftiqueform.data[id] = $("#" + id).val()
        localStorage.giftiquedata = true
        localStorage[id] = giftiqueform.data[id]
    $(".put-name").html giftiqueform.data.recipient

  giftiqueform.hideresults = (name) ->
    $("#" + name + "-results").slideUp()

  giftiqueform.etsysearch = (ajax_list) ->
    api_key = "muf6785p5zsu3iwp28e51kgi"
    terms = ajax_list[0].val
    write_to = ajax_list[0].name
    etsyURL = "http://openapi.etsy.com/v2/listings/active.js?keywords=" + terms
    if giftiqueform.data.pricerange
      p = giftiqueform.data.pricerange.split("-")
      etsyURL += "&min_price=" + p[0] + "&max_price=" + p[1]
    etsyURL += "&occasion=" + giftiqueform.data.occasion  if giftiqueform.data.occasion
    
    #&recipient=women
    etsyURL += "&limit=5&includes=Images:1&sort_on=score&api_key=" + api_key
    $("#" + write_to + "-results").empty()
    $("<p></p>").text("Searching for " + terms).appendTo "#" + write_to + "-results"
    $.ajax
      url: etsyURL
      async: false
      dataType: "jsonp"
      success: (data) ->
        if data.ok
          $("#" + write_to + "-results").empty()
          if data.count > 0
            $("<p>Based on your interest in " + terms + " (<button type=\"button\" onclick=\"giftiqueform.hideresults('" + write_to + "')\">Irrelevant?</button>):</p>").appendTo "#" + write_to + "-results"
            data.results.sort (a, b) ->
              (if a.views < b.views then 1 else -1)

            $.each data.results, (i, item) ->
              $("<div class=\"giftitem\" id=\"" + write_to + i + "\"><p style=\"display:inline;float:left\">Views: " + item.views + "</p><p style=\"display:inline;float:right\">$" + item.price + "</p></div>").appendTo "#" + write_to + "-results"
              $("<img/>").attr("src", item.Images[0].url_170x135, "alt", item.title).appendTo("#" + write_to + i).wrap "<a href='" + item.url + "'></a>"
              $("<img/>").attr("src", "etsy.png", "alt", "From Etsy.com").addClass("product_source").appendTo "#" + write_to + i

          else
            $("<p>No results.</p>").appendTo "#" + write_to + "-results"
          giftiqueform.etsysearch ajax_list.splice(1)  if ajax_list.length > 1
        else
          $("#" + write_to + "-results").empty()
          alert data.error

    false
  return giftiqueform
root = exports ? this
root.giftiqueform = giftiqueform