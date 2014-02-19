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
        <form id="simple_form" onsubmit="return false">
          <input type="text" name="first"/>
          <input type="text" name="last"/>
          <input type="submit" value="Submit" />
        </form>
        >>;
    }
    if (not ent:user) then {
      append("body", div);
      watch("#simple_form", "submit");
    }
  }
  rule show_div {
    select when pageview ".*" setting ()
    pre {
      div = <<
        <div class="results">
          <h3>Hello</h3>
          <h3 id="username"></h3>
        </div>
        >>;
    }
    if (ent:user) then {
      append("body", div);
      append("#username", ent:user);
    }
  }
  rule form_submit {
    select when web submit "#simple_form"
    pre {
      username = event:attr("first")+" "+event:attr("last");
    }
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
