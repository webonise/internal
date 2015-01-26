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

Configuration
----------------

The common configuration is done in `config.rb`, based on `config.sample.rb`. This is where configuration used by all scripts should go.

Each script also optionally takes a `#{SCRIPTNAME}_config.rb` file, which provides the script-specific configuration values. You can also redefine
constants, which you can do by doing something like the following from `#{SCRIPTNAME}_config.rb`:

```ruby
include RedefineConstant
redefine_constant(:USERNAME, "RobertFischer")
redefine_constant(:PASSWORD, "My Awesome Password")
```

Logger
-------

By default, logging messages are written to standard error using Ruby's built-in message format.
You can customize this behavior by manipulating or redefining the `LOGGER` constant in your configuration.

Writing a Script
------------------

If you want to write a script, the opening line is:

```ruby
require_relative "init"
```

That gives you the following:

1. `config.rb` and `#{SCRIPTNAME}_config.rb` loading.
1. [Octokit](http://octokit.github.io/octokit.rb/) configuration, including verifying the user's login
1. `LOGGER` loaded/configured
1. `print_hash` for printing out hashes
1. `nice_author` for turning author names as reported by GitHub into something nicer to read

If you want to use additional configuration values, use the `default_constant` method (provided by `init`) as so:

```ruby
default_constant :PULL_STATE, "all"
```

That will enable people to provide values for your constant in their configuration without generating warnings.

After that is done, go nuts with Octokit. Print your results to standard out.
