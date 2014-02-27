ruleset lab4 {
  meta {
    name "lab4"
    author "Addison Higham"
    description <<
      Display some rotten tomatoes stuff
    >>
    logging on
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
  }
  dispatch {
  }
  global {
    get_rt = function(title) {
      http:get("http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=uaxxdhszngfsw96wxs6hx8hw&page_limit=1&q=" + uri:escape(title)).pick("$.content").decode().pick("$.movies[0]")
    };
  }
  rule show_form {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <h5>Enter a movie title!</h5>
        <form id="simple_form" onsubmit="return false">
          <input type="text" name="title"/>
          <input type="submit" value="Submit" />
        </form>
        <div id="results"></div>
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Enter a title", {}, my_html);
      watch("#simple_form", "submit");
    }
  }
  rule form_submit {
    select when web submit "#simple_form"
    pre {
      movie = event:attr("title");
      mj = get_rt(movie).klog("what did we get back?");
    }
    if (mj.length() != 0) then {
      emit <<
        console.log(mj);
        >>;
      replace_inner("#results", mj.pick("$.title"));
    }

    notfired {
      raise explicit event no_results;
    }
  }
  rule no_results {
    select when explicit no_results
    replace_inner("#results", "Couldn't find any results");
  }
  rule process_error {
    select when system error
    pre{
      genus = event:attr("genus");
      species = event:attr("species");
    }
    {
      notify("had an error" + genus + species);
    }
  }
}
