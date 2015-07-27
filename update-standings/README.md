# League Standings Updater

For a local rec-sports league's website, we have to calculate the new league 
rankings after each week's games. The website is written in Ruby on Rails and 
the code runs in a nightly job. It's a good example of my understanding of 
separation of concerns in an Object-Oriented application.

## Architecture

A nightly Rake task (not included) calls the `update_standings!` method on
each active league. This method is reproduced in `models/League.rb`. 

`League.update_standings!` instructs each team to calculate its own up-to-date
statistics by calling `Team.update_stats` (not included) and then calling `sort!`
on an array of teams. Once the teams are sorted, it assigns them new ranks, which
are cached in the database, because the tie breakers can be very expensive to compute.

The Team class defines a comparison method, `Team.<=>` which handles all tie 
breakers and makes the sort call in `League.update_standings!` work like magic. 
This method is located in `models/Team.rb`.


-----
The full rec-sports league repository is open source and 
[located on GitHub](https://github.com/AFDC/Platinum).
