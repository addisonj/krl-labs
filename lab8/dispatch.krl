ruleset lab8 {
  meta {
    name "lab8"
    author "Addison Higham"
    logging off
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
  }
  dispatch {
    // domain "exampley.com"
  }
  rule location_catch {
    select when location notification
    pre {
      venue_name = event:attr("venue_name");
      city = event:attr("city");
      shout = event:attr("shout");
      created_at = event:attr("created_at");
      lat = event:attr("lat");
      long = event:attr("long");
    }
    every {
      send_directive("venue_name") with checkin = venue_name;
    }
    fired {
      set ent:venue_name venue_name;
      set ent:city city;
      set ent:shout shout;
      set ent:created_at created_at;
      set ent:lat lat;
      set ent:long long;
    }
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
  rule display_checkin {
    select when web cloudAppSelected
    pre {
      venue_name = ent:venue_name;
      city = ent:city;
      shout = ent:shout;
      created_at = ent:created_at;
      check_html = <<
        <h3>You checked into #{venue_name} in #{city}</h3>
        <p>You shouted <span id="shout-text"></span></p>
        <p>This happened on <span id="created-text"></span></p>
      >>;
    }
    {
      replace_inner("#checkins", check_html);
      emit <<
        console.log("YOOOOO", venue_name);
          if (shout && shout.length) {
            $K('#shout-text').append(shout);
          } else {
            $K('#shout-text').append("nothing, how boring!");
          }
          var d = new Date();
          d.setTime(created_at * 1000);
          $K('#created-text').append(d.toString());
        >>;
    }
  }
  rule display_empty {
    select when web cloudAppSelected
    pre {
      venue_name = ent:venue_name;
    }
    if (venue_name.isnull()) then {
      replace_inner("#checkins", "No checkins!");
    }
  }
}
