ruleset lab6 {
  meta {
    name "lab6"
    author "Addison Higham"
    logging off
    provides get_location_data
  }
  global {
    get_location_data = function(k) {
      ent:locations{k};
    };
  }
  rule add_location_item {
    select when pds new_location_data
    pre {
      k = event:attr("key");
      val = event:attr("value");
    }
    send_directive(k) with location = val;
    always {
      set ent:locations{k} val;
    }
  }
}
