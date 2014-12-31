require 'octokit'
require 'faraday/http_cache'
require 'pp'
require './config.rb'

# Describes out to print a hash: if you don't like it, define it in your config.rb
unless self.respond_to? :print_hash
  def print_hash(hash)
    hash.each do |k,v|
      puts "#{k}:\t\t#{v}"
    end
  end
end

# Provide authentication credentials
Octokit.configure do |c|
  c.login = USERNAME
  c.password = PASSWORD
  c.auto_paginate = true
  c.api_endpoint = API_ENDPOINT unless API_ENDPOINT.empty? if API_ENDPOINT
  c.web_endpoint = WEB_ENDPOINT unless WEB_ENDPOINT.empty? if WEB_ENDPOINT
end

# Cache responses to stretch our rate limit
Octokit.middleware = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end

# Basic sanity check
puts "Executing as #{Octokit.user.login}"

# Retrieve the pull requests
pulls = []
BRANCHES.each do |branch|
  puts "Retrieving #{PULL_STATE} pull requests against #{branch} for #{REPO}"
  pulls = pulls + Octokit.pulls(REPO, {
    :state => PULL_STATE,
    :base => branch
  })
end

# Print out a pull request to ensure you see them
if DEBUG
  puts "Sample pull request:"
  PP.pp(pulls[0])
end

# Count pulls by user
puts "Pull Requests by User:"
pulls_by_user = Hash.new { |hash, key| hash[key] = 0 }
pulls.each do |pull|
  pulls_by_user[pull.user.login] += 1
end
print_hash(pulls_by_user)
