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
  slides = ->
    $slider.find $slide
  #Try to load previously entered info
  if localStorage.giftiquedata
    for id of giftiqueform.data
      if localStorage[id]
        giftiqueform.data[id] = localStorage[id]
        $("#" + id).val localStorage[id]
  $slider = $("#giftiqueform")
  $slide = $(".item")
  $active_slide = 0

  $slider.bind "slid", ->
    $active_slide = slides().index $slider.find $(".item.active")
    if $active_slide is 0
      $("#form-back").addClass "disabled"
      $("#form-back").removeAttr "data-slide"
    else
      $("#form-back").removeClass "disabled"
      $("#form-back").attr "data-slide", "prev"
    if $active_slide is 4
      $("#form-cont").removeAttr "data-slide"
      $("#form-cont").html "Finish!"
    else
      $("#form-cont").attr "data-slide", "next"
      $("#form-cont").html "Continue"
  
  #process form changes on continue
  giftiqueform.cont = ->
    giftiqueform.getinput()
    giftiqueform.finish()  if $active_slide is 4
      
  #process form changes on back
  giftiqueform.back = ->
    giftiqueform.getinput()

  giftiqueform.finish = ->
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
    $(name).fadeOut()

  giftiqueform.etsysearch = (ajax_list) ->
    api_key = "muf6785p5zsu3iwp28e51kgi"
    terms = ajax_list[0].val
    write_to = ajax_list[0].name
    etsyURL = "http://openapi.etsy.com/v2/listings/active.js?keywords=" + terms
    if giftiqueform.data.pricerange
      p = giftiqueform.data.pricerange.split("-")
      etsyURL += "&min_price=" + p[0] + "&max_price=" + p[1]
    etsyURL += "&occasion=" + giftiqueform.data.occasion  if giftiqueform.data.occasion
    
    etsyURL += "&limit=5&includes=Images:1&sort_on=score&api_key=" + api_key
    $("#" + write_to + "-results").empty()
    $("<img/>").attr("src","loading.gif").appendTo "#" + write_to + "-results"
    $.ajax
      url: etsyURL
      async: true
      dataType: "jsonp"
      success: (data) ->
        if data.ok
          $("#" + write_to + "-results").empty()
          if data.count > 0
            $("<p>Based on your interest in " + terms + ":</p>").appendTo "#" + write_to + "-results"
            data.results.sort (a, b) ->
              (if a.views < b.views then 1 else -1)

            $.each data.results, (i, item) ->
              $('<div class="giftitem" id="' + write_to + i + '\"><p class="pull-left">&nbsp;Views: ' + item.views + '</p><p class="pull-right">$' + item.price + "&nbsp;</p></div>").appendTo "#" + write_to + "-results"
              $("<a></a>").addClass("btn product_thumb").attr("onclick","giftiqueform.hideresults(" + write_to + i + ")").append('<i class="icon-thumbs-down"></i>').appendTo "#" + write_to + i
              $("<img/>").attr("src", "etsy.png", "alt", "From Etsy.com").addClass("product_source").appendTo "#" + write_to + i
              $("<img/>").attr("src", item.Images[0].url_170x135, "alt", item.title).appendTo("#" + write_to + i).wrap "<a href='" + item.url + "'></a>"

          else
            $("<p>No results.</p>").appendTo "#" + write_to + "-results"
          giftiqueform.etsysearch ajax_list.splice(1)  if ajax_list.length > 1
        else
          $("#" + write_to + "-results").empty()
          alert data.error

  return giftiqueform
root = exports ? this
root.giftiqueform = giftiqueform