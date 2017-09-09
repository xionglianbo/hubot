# common functions

exports.str_pad = (input, pad_length, pad_string, pad_type) ->
    half = ""
    pad_to_go = undefined
    str_pad_repeater = (s, len) ->
      collect = ""
      i = undefined
      collect += s  while collect.length < len
      collect = collect.substr(0, len)
      collect

    input += ""
    pad_string = (if pad_string isnt `undefined` then pad_string else " ")
    pad_type = "STR_PAD_RIGHT"  if pad_type isnt "STR_PAD_LEFT" and pad_type isnt "STR_PAD_RIGHT" and pad_type isnt "STR_PAD_BOTH"
    if (pad_to_go = pad_length - input.length) > 0
      if pad_type is "STR_PAD_LEFT"
        input = str_pad_repeater(pad_string, pad_to_go) + input
      else if pad_type is "STR_PAD_RIGHT"
        input = input + str_pad_repeater(pad_string, pad_to_go)
      else if pad_type is "STR_PAD_BOTH"
        half = str_pad_repeater(pad_string, Math.ceil(pad_to_go / 2))
        input = half + input + half
        input = input.substr(0, pad_length)
    input


Date::format = (formatStr) ->
  date = this
  zeroize = (value, length) ->
    length = 2  unless length
    value = new String(value)
    i = 0
    zeros = ""

    while i < (length - value.length)
      zeros += "0"
      i++
    zeros + value

  formatStr.replace /"[^"]*"|'[^']*'|\b(?:d{1,4}|M{1,4}|yy(?:yy)?|([hHmstT])\1?|[lLZ])\b/g, ($0) ->
    switch $0
      when "d"
        date.getDate()
      when "dd"
        zeroize date.getDate()
      when "ddd"
        [
          "Sun"
          "Mon"
          "Tue"
          "Wed"
          "Thr"
          "Fri"
          "Sat"
        ][date.getDay()]
      when "dddd"
        [
          "Sunday"
          "Monday"
          "Tuesday"
          "Wednesday"
          "Thursday"
          "Friday"
          "Saturday"
        ][date.getDay()]
      when "M"
        date.getMonth() + 1
      when "MM"
        zeroize date.getMonth() + 1
      when "MMM"
        [
          "Jan"
          "Feb"
          "Mar"
          "Apr"
          "May"
          "Jun"
          "Jul"
          "Aug"
          "Sep"
          "Oct"
          "Nov"
          "Dec"
        ][date.getMonth()]
      when "MMMM"
        [
          "January"
          "February"
          "March"
          "April"
          "May"
          "June"
          "July"
          "August"
          "September"
          "October"
          "November"
          "December"
        ][date.getMonth()]
      when "yy"
        new String(date.getFullYear()).substr 2
      when "yyyy"
        date.getFullYear()
      when "h"
        date.getHours() % 12 or 12
      when "hh"
        zeroize date.getHours() % 12 or 12
      when "H"
        date.getHours()
      when "HH"
        zeroize date.getHours()
      when "m"
        date.getMinutes()
      when "mm"
        zeroize date.getMinutes()
      when "s"
        date.getSeconds()
      when "ss"
        zeroize date.getSeconds()
      when "l"
        date.getMilliseconds()
      when "ll"
        zeroize date.getMilliseconds()
      when "tt"
        (if date.getHours() < 12 then "am" else "pm")
      when "TT"
        (if date.getHours() < 12 then "AM" else "PM")
