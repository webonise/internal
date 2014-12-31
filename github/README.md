GitHub Scripts
===============

These are various utility scripts to tell you about the state of GitHub.

To use them, first copy `config.sample.rb` to `config.rb` and set the variables appropriately: if they aren't obvious,
they should be documented better in `config.sample.rb`.

You will then need to do a `bundle install` to get the gems in the appropriate place.

Once that is done, you can just run the script to get the results.

rbenv
------

We use `rbenv` to fix the version of Ruby: `octokit` has some limitations. You are encouraged to install `rbenv` to make your life easier in the future.
