ruleset lab7 {
  meta {
    name "lab7"
    author "Addison Higham"
    logging off
    use module b505196x5 alias Location
    // ECI: 4A2F5784-AE44-11E3-8DE1-E08D833561DC
    // https://cs.kobj.net/sky/event/4A2F5784-AE44-11E3-8DE1-E08D833561DC/1/location/cur
  }
  dispatch {
  }
  rule nearby {
    select when location cur
    pre {
      lat = event:attr("lat");
      long = event:attr("long");
      r90 = math:pi()/2;
      rEk = 6378;         // radius of the Earth in km

      // point b
      checkin = Location:get_location_data("fs_checkin");
      latb  = checkin{"lat"};
      lngb  = checkin{"long"};

      // convert co-ordinates to radians
      rlata = math:deg2rad(lat);
      rlnga = math:deg2rad(long);
      rlatb = math:deg2rad(latb);
      rlngb = math:deg2rad(lngb);

      // distance between two co-ordinates in kilometers
      dE = math:great_circle_distance(rlnga,r90 - rlata, rlngb,r90 - rlatb, rEk);
    }
    send_directive("location_sent") with distance = dE and curLat = checkin{"lat"} and curLong = checkin{"long"} and cLat = latb and cLong = lngb;
    always {
      raise explicit event 'location_nearby' with distance = dE if dE < 8;
      raise explicit event 'location_far' with distance = dE if dE >= 8;
    }
  }
}
