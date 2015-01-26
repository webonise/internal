require_relative 'init'

PULL_STATE = "all" unless defined? PULL_STATE

# Retrieve the pull requests
pulls = []
REPOS.each do |repo|
  BRANCHES.each do |branch|
    LOGGER.info "Retrieving #{PULL_STATE} pull requests against #{branch} for #{repo}"
    pulls = pulls + Octokit.pulls(repo, {
      :state => PULL_STATE,
      :base => branch
    })
  end
end

# Print out a pull request to ensure you see them
if DEBUG
  LOGGER.info "Sample pull request:"
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
  joined_hash[user] = pulls_by_user[user].to_s + "\tMost recent: " + last_pull_by_user[user].to_s
end
print_hash joined_hash
