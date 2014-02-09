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
    // Display notification that will not fade.
    {
      notify("Note 1", "This is the first notification");
      notify("Note 2", "This is the second notification");
    }
  }
  rule query_param {
    select when pageview ".*" setting ()
    pre {
      query_params = page:url("query");
      extract_param = function(qps, param_name) {
        ex = ("/.*" + param_name + "=(\w*)&?").as("regexp")
        qps.extract(ex)
      };
      name_param = extract_param(query_params, "name")
    }
    // Display notification that will not fade.
    {
      notify("Hello", name_param || "Monkey");
    }
  }
}
