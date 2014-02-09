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
        notify("Note 1", "This is the first notification") with sticky;
        notify("Note 2", "This is the second notification") with sticky;
    }
}
