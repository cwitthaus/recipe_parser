# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

get_updated_content = (association, content) ->
  new_id = new Date().getTime()
  regexp = new RegExp("new_" + association, "g")
  return content.replace(regexp, new_id)

@add_ingredient_fields = (association, content) ->
  content = get_updated_content(association, content)
  $(".ingredients").append(content)
  return

@add_step_fields = (association, content) ->
  content = get_updated_content(association, content)
  $(".steps").append(content)
  return

@remove_fields = (link) ->
  $(link).prev("input[type=hidden]").val("1")
  $(link).parent().hide()
  return