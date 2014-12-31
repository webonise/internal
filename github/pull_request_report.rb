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
REPOS.each do |repo|
  BRANCHES.each do |branch|
    puts "Retrieving #{PULL_STATE} pull requests against #{branch} for #{repo}"
    pulls = pulls + Octokit.pulls(repo, {
      :state => PULL_STATE,
      :base => branch
    })
  end
end

# Print out a pull request to ensure you see them
if DEBUG
  puts "Sample pull request:"
  PP.pp(pulls[0])
end

# Count pulls by user
puts "Pull Requests by User:"
pulls_by_user = Hash.new { |hash, key| hash[key] = 0 }
last_pull_by_user = Hash.new { |hash,key| Time.new(0) }
pulls.each do |pull|
  user = pull.user.login

  pulls_by_user[user] += 1

  prev_date = last_pull_by_user[user]
  curr_date = pull.created_at
  last_pull_by_user[user] = curr_date if prev_date < curr_date
end
joined_hash = Hash.new
pulls_by_user.keys.each do |user|
  joined_hash[user] = pulls_by_user[user].to_s + "\t" + last_pull_by_user[user].to_s
end
print_hash joined_hash
