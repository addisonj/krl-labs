ruleset HelloWorldApp {
  meta {
    name "Hello World"
    description <<
      Hello World
    >>
    author "Addison Higham"
    logging off
  }
  global {

  }
  rule HelloWorld {
    select when web cloudAppSelected
  }
}
