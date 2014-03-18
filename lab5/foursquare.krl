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
      checkinRaw = event:attr("checkin").decode();
      checkin = checkinRaw.decode();
      venue_name = checkin.pick("$.venue.name");
      city = checkin.pick("$.venue.location.city");
      shout = checkin.pick("$.shout");
      created_at = checkin.pick("$.createdAt");
      lat = checkin.pick("$.venue.location.lat");
      long = checkin.pick("$.venue.location.lng");
    }
    every {
      replace_inner("#status", "Just got a checkin!");
      send_directive("venue_name") with checkin = venue_name;
    }
    fired {
      set ent:checkin checkin;
      set ent:venue_name venue_name;
      set ent:city city;
      set ent:shout shout;
      set ent:created_at created_at;
      raise pds event new_location_data
        with key = "fs_checkin"
        and value = {
          "venue" : venue_name,
          "city" : city,
          "shout" : shout,
          "createdAt" : created_at,
          "lat" : lat,
          "long" : long
        };
    }
  }
  rule display_checkin {
    select when web cloudAppSelected
    pre {
      checkin = ent:checkin;
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
    if (venue_name) then {
      replace_inner("#checkins", check_html);
      emit <<
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
