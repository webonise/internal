# Dirty, evil hack from http://stackoverflow.com/a/3377188
module RedefineConstant
  def redefine_constant(symbol,value)
    self.class.send(:remove_const, symbol) if self.class.const_defined?(symbol)
    self.class.const_set(symbol, value)
  end
end

# Ability to provide default values for constants
module DefaultConstant
  def default_constant(symbol, value)
    self.class.const_set(symbol, value) unless self.class.const_defined?(symbol)
  end
end
include DefaultConstant

# Provide access to useful bits of active_support
require 'active_support'                    # Useful since Rails hand-rolled autoload for reasons known only to God and DHH
require 'active_support/core_ext/date'      # Required for the date arithmetic we want below
require 'active_support/core_ext/numeric'   # Provides 3.days.ago and the like

# Configure the logger
require 'logger'
LOGGER = Logger.new(STDERR)
logger = LOGGER # So I don't have to yell so much
logger.formatter = proc do |severity, datetime, progname, msg|
  datetime = datetime.strftime("%I:%M.%S%p")
  sprintf("%s %-5s\t%s\n", datetime, severity, msg)
end

# Constant defining exit codes: feel free to add your own!
EXIT_CODES = {
  :MISSING_CONFIGURATION => -2
}

# Load the common config file (mandatory)
configFileName = "./config.rb"
if File.file? configFileName
  logger.info "Loading #{configFileName}"
  require configFileName
else
  sampleConfigFileName = configFileName.sub(/\.rb$/, ".sample.rb")
  logger.fatal "Please copy #{sampleConfigFileName} to #{configFileName} and edit it before running #{$0}"
  exit EXIT_CODES[:MISSING_CONFIGURATION]
end

# Load the script config file (optional)
scriptConfigFileName = $0.sub(/\.rb/, "_config.rb");
if File.file? scriptConfigFileName
  scriptConfigFileName = "./#{scriptConfigFileName}"
  logger.info "Loading #{scriptConfigFileName}"
  require scriptConfigFileName
else
  logger.info "No configuration file at #{scriptConfigFileName}; you can add script-specific configuration there, if you'd like"
end

# Describes out to print a hash: if you don't like it, redefine it in your config
unless self.respond_to? :print_hash
  def print_hash(hash)
    hash.each do |k,v|
      printf "%20s => %s\n", k, v
    end
  end
end

# Load Octokit
require 'octokit'
require 'faraday/http_cache'

# Provide authentication credentials
Octokit.configure do |c|
  c.login = USERNAME
  c.password = PASSWORD
  c.auto_paginate = true
  c.api_endpoint = API_ENDPOINT unless API_ENDPOINT.empty? if API_ENDPOINT
  c.web_endpoint = WEB_ENDPOINT unless WEB_ENDPOINT.empty? if WEB_ENDPOINT
end

Octokit.middleware = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache            # Cache responses to stretch our rate limit
  builder.use Octokit::Response::RaiseError # Raise error on bad status codes
  builder.adapter Faraday.default_adapter   # Use Faraday's default adapter, because Octokit says to
end

# Basic sanity check: queries GitHub for the user information
logger.info "Executing as #{Octokit.user.login}"
