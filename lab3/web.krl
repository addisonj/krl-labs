ruleset lab2 {
  meta {
    name "lab3"
    author "Addison Higham"
    logging off
  }
  dispatch {
  }
  global {
    decode_content = function(content) {
      content.split(re/&/).map(function(x){x.split(re/=/)}).collect(function(a){a[0]}).map(function(k,v){a = v[0];a[1]})
    };
  }
  rule show_form {
    select when pageview ".*" setting ()
    pre {
      div = <<
        <div class="form">
          <form id="simple_form" onsubmit="return false">
            <input type="text" name="first"/>
            <input type="text" name="last"/>
            <input type="submit" value="Submit" />
          </form>
        </div>
        >>;
      name = ent:first_name + ent:last_name;
    }
    {
      append(".div_wrapper", div);
      watch("#simple_form", "submit");
    }
  }
  rule show_div {
    select when pageview ".*" setting ()
    pre {
      div = <<
        <div class="results">
          <h3>Does this work?</h3>
        </div>
        >>;
      name = ent:first_name + ent:last_name;
    }
    if (name) then {
      append(".div_wrapper", div);
    }
  }
  rule form_submit {
    select when web submit "#simple_form"
    pre {
      username = event:attr("first")+" "+event:attr("last");
    }
    replace_inner("#my_div", "Hello #{username}");
    fired {
      set ent:user username;
    }
  }
  rule clear_user {
    select when pageview ".*" setting ()
    pre {
      query_params = page:url("query");
      decoded = decode_content(query_params);
      clear_param = decoded{"clear"};
    }
    if clear_param then
      notify("clearing your user", clear_param)
    fired {
      clear ent:user;
    }
  }
}
