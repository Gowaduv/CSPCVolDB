# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(document).on 'change', '#position_select', (evt) ->
    position_id = $("#position_select option:selected").val()
    $.ajax '/positions/'+position_id+'/qualified_users',
      type: 'GET'
      dataType: 'script'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic user select ok!")      