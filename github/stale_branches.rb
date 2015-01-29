# Provides a report of the stale branches up on GitHub

require_relative 'init'

# Configuration Constants
default_constant :STALE_THRESHOLD, 2.weeks.ago
default_constant :ORG, "webonise"
default_constant :REPOS, nil
default_constant :IGNORE_BRANCHES, ["master","stable","develop"]

# What we do when we find a stale branch
def print_stale_branch(repo, branch)
  LOGGER.debug "Retrieving commits for #{repo} - #{branch.name}. This may take a while!"
  commits = Octokit.commits repo, {:sha => branch.name} # Yes, :sha => branch.name
  LOGGER.debug "Retrieved commits for #{repo} - #{branch.name}."

  authors = commits.collect do |commit|
    "'#{nice_author(commit.commit.author.name)}'"
  end
  authors.uniq!
  authors.sort!

  msg = "#{repo} - #{branch.name} is stale\n"
  commit = branch.commit.commit
  msg += "\tLast Commit:\t#{nice_author(commit.author.name)}\t#{time_ago_in_words(commit.author.date)} ago\t#{commit.sha}\n"
  msg += "\tBranch Authors:\t#{authors.join(", ")}"

  return msg
end

# Retrieve the repos if we're supposed to
repos = REPOS
if repos.blank?
  LOGGER.info("Retrieving all the repositories for #{ORG}")
  repos = []
  org_repos = Octokit.org_repos(ORG)
  org_repos.each do |org_repo|
    repos.push(org_repo.name)
  end
  LOGGER.info("Found #{repos.size} repositories for #{ORG}")
end

# Retrieve the branches
branches = Hash.new { Array.new }
repos.each do |repo|
  repo = "#{ORG}/#{repo}"
  LOGGER.info "Retrieving branch information from #{repo}"
  repo_branches = Octokit.branches repo
  LOGGER.info "Found #{repo_branches.blank? ? 0 : repo_branches.size} branches in #{repo}"

  unless repo_branches.blank?
    LOGGER.debug { "Sample branch summary: #{repo_branches[0].pretty_inspect}" }
  end

  repo_branches.reject! do |branch|
    IGNORE_BRANCHES.include? branch.name
  end

  repo_branches.each do |branch|
    LOGGER.info "Retrieving branch information from #{repo} branch '#{branch.name}'"
    branch = Octokit.branch repo, branch.name
    LOGGER.debug { "'#{branch.name}' branch details: #{branch.pretty_inspect}" }

    # Straight up .push was not working. I don't know why.
    branches_array = branches[repo]
    branches[repo] = branches_array.push(branch)
  end
end

LOGGER.debug { "Branches: #{branches.pretty_inspect}" }

# Now go looking for stale branches
messages = []
branches.each_pair do |repo, branch_list|
  LOGGER.info "Now checking branches for #{repo}; seeing if any are stale"
  branch_list.each do |branch|
    LOGGER.debug "Checking the #{branch.name} branch for staleness"
    last_update = branch.commit.commit.committer.date
    LOGGER.debug { "Checking #{last_update.rfc822} versus #{STALE_THRESHOLD.rfc822}" }
    if last_update < STALE_THRESHOLD
      LOGGER.info "#{repo} - #{branch.name} is stale; fetching details"
      messages.push(print_stale_branch repo, branch)
    end
  end
end
messages.sort!
puts messages.join("\n\n")
puts "\nFound #{messages.size} total stale branch(es)\n\n"
