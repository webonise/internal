# Provides a count of pull requests broken down by user, along with the most recent time for a pull request by that user.

require_relative 'init'

default_constant :PULL_STATE, "all"

# Retrieve the pull requests
pulls = []
REPOS.each do |repo|
  LOGGER.debug "Querying #{repo} branches: #{BRANCHES}"
  BRANCHES.each do |branch|
    LOGGER.info "Retrieving #{PULL_STATE} pull requests against #{branch} for #{repo}"
    branch_pulls = Octokit.pulls(repo, {
      :state => PULL_STATE,
      :base => branch
    })
    LOGGER.debug { "Pulls for #{branch} of #{repo}: #{branch_pulls.pretty_inspect}" }
    pulls.concat(branch_pulls)
  end
end
LOGGER.info("Found #{pulls.size} total pull requests.")

# Print out a pull request to ensure you see them
LOGGER.debug {"Sample pull request: #{pulls[0].pretty_inspect}" }

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
  joined_hash[user] = pulls_by_user[user].to_s + "\tMost recent: " + last_pull_by_user[user].to_s
end
print_hash joined_hash
