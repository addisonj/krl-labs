ruleset lab2 {
  meta {
    name "lab2"
    author "Addison Higham"
    logging off
  }
  dispatch {
    // domain "exampley.com"
  }
  rule first_rule {
    select when pageview ".*" setting ()
    {
      notify("Note 1", "This is the first notification");
      notify("Note 2", "This is the second notification");
    }
  }
  rule query_param {
    select when pageview ".*" setting ()
    pre {
      query_params = page:url("query");
      decode_content = function(content) {
        content.split(re/&/).map(function(x){x.split(re/=/)}).collect(function(a){a[0]}).map(function(k,v){a = v[0];a[1]})
      };
      decoded = decode_content(query_params);
      name_param = decoded{"name"};
    }
    {
      notify("Hello", name_param || "Monkey");
    }
  }
  rule count_user {
    select when pageview ".*" setting ()
    if ent:visit_count < 6 then
      notify("You have visited", ent:visit_count)
    fired {
      ent:visit_count += 1 from 1;
    }
  }
  rule clear_count_user {
    select when pageview ".*" setting ()
    pre {
      query_params = page:url("query");
      decode_content = function(content) {
        content.split(re/&/).map(function(x){x.split(re/=/)}).collect(function(a){a[0]}).map(function(k,v){a = v[0];a[1]})
      };
      decoded = decode_content(query_params);
      clear_param = decoded{"clear"};
    }
    if clear_param then
      notify("clearing your visit count", clear_param)
    fired {
      clear ent:visit_count;
    }
  }
}
