ruleset lab5 {
  meta {
    name "lab5"
    author "Addison Higham"
    description <<
      Display some rotten tomatoes stuff
    >>
    logging on
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
    // my eci
    //690BA504-A3B3-11E3-B2BD-307CD61CF0AC
    // full url
    // https://cs.kobj.net/sky/event/690BA504-A3B3-11E3-B2BD-307CD61CF0AC/1/foursquare/checkin
  }
  dispatch {
  }
  global {
  }
  rule load_view {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <h2>Checkins</h2>
        <div id="checkins"></div>
        <div id="status"></div>
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Foursquare", {}, my_html);
    }
  }
  rule process_fs_checkin {
    select when foursquare checkin
    pre {
      checkin = event:attr("checkin");
    }
    replace_inner("#status", "Just got a checkin!");
    fired {
      set ent:venue_name checkin.pick("$.venue.name");
      set ent:city checkin.pick("$.venue.location.city");
      set ent:shout checkin.pick("$.shout");
      set ent:created_at checkin.pick("$.createdAt");
    }
  }
  rule display_checkin {
    select when web cloudAppSelected
    pre {
      check_html = <<
        <h3>You checked into #{ent:venue_name} in #{ent:city}</h3>
        <p>You shouted #{ent:shot}</p>
        <p>This happened on #{ent:created_at}</p>
      >>:
    }
    if (ent:venue_name) {
      replace_inner("#checkins", check_html);
    }
  }
}
