ruleset lab6_view {
  meta {
    name "lab6_view"
    author "Addison Higham"
    description <<
    >>
    logging on
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
    use module b505196x5 alias Location
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
  rule display_checkin {
    select when web cloudAppSelected
    pre {
      checkin = Location:get_location_data("fs_checkin");
      venue_name = checkin{"venue"};
      city = checkin{"city"};
      shout = checkin{"shout"};
      created_at = checkin{"created_at"};
      check_html = <<
        <h3>You checked into #{venue_name} in #{city}</h3>
        <p>You shouted <span id="shout-text"></span></p>
        <p>This happened on <span id="created-text"></span></p>
      >>;
    }
    if (venue_name) then {
      replace_inner("#checkins", check_html);
      emit <<
          console.log(checkin)
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
    notfired {
      raise explicit event no_results;
    }
  }
  rule display_empty {
    select when explicit no_results
    {
      replace_inner("#checkins", "No checkins!");
    }
  }
}
