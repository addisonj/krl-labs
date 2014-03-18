ruleset send_sms {
  meta {
    name "lab7"
    author "Addison Higham"
    logging off
    key twilio {
      "account_sid" : "AC638bf3da59bcf18cd68917a69c2c9c1b",
      "auth_token" : "651cf6f1ac5d2e83d848e9e14cedf741"
    }
    use module a8x115 alias twilio with twiliokeys = keys:twilio()
  }
  dispatch {
    // domain "exampley.com"
  }
  rule location_nearby {
    select when explicit location_nearby
    pre {
      d = event:attr("distance");
    }
    twilio:send_sms("208-697-9297", "208-402-5668", "Your are #{d} K away");
  }
}
