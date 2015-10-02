$("#user_select").empty().append("<%= escape_javascript(render(:partial => 'staffs/user', :collection => @users)) %>").append("<option value>No permanent volunteer</option>")
