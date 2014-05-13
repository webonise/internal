require 'yaml'
require 'ostruct'

class Object
	def blank?
		nil? or empty?
	end
end

class WeboniseSkype

	def initialize
		users_file = 'users.yaml'
		users_file = File.join(__dir__, users_file)
		@users = YAML::load_file(users_file)
		@user_lookup = Hash.new do |hash,key|
			if key != key.downcase
				hash[key] = hash[key.downcase] 
				hash[key]
			else
				nil
			end
		end
		@users.each_pair do |key,value|
			user = OpenStruct.new(value)
			user.id = key
			@users[key] = user
			@user_lookup[key] = user
			@user_lookup[key.downcase] = user
			@user_lookup[key.sub(/\s+/,'.')] = user
			@user_lookup[key.sub(/\s+/,'.').downcase] = user
			unless user[:aliases].blank?
				user.aliases.each do |other_name|
					@user_lookup[other_name] = user
					@user_lookup[other_name.downcase] = user
				end
			end
			unless user[:name].blank?
				user.name.split(/\s+/).each do |name_part|
					@user_lookup[name_part] = user
					@user_lookup[name_part.downcase] = user
				end
			end
		end
		puts "Users: #{@users.inspect}"

		calls_file = 'calls.yaml'
		calls_file = File.join(__dir__, calls_file)
		@calls = YAML::load_file(calls_file)
		@calls_lookup = Hash.new do |hash,key|
			if key != key.downcase
				hash[key] = hash[key.downcase] 
				hash[key]
			else
				nil
			end
		end
		@calls.each_pair do |key,value|
			call = OpenStruct.new(value)
			call.id = key
			unless call[:users].blank?
				call.users = call.users.collect do |user|
					@user_lookup[user] || OpenStruct.new(:id=>user)
				end
			end
			call.name = call.id if call[:name].blank?
			@calls[key] = call
			@calls_lookup[key] = call
		end
		puts "Calls: #{@calls.inspect}"
	end

	def calls
		@calls.values
	end

	def call_groups
		if @call_groups.blank?
			@call_groups = Hash.new([])
			calls.each do |c|
				group = c.group || 'Ungrouped'
				@call_groups[group] << c
			end
		end
		@call_groups
	end

	def users
		@users.values
	end

	def call(id)
		id if id.blank?
		@call_lookup[id] or raise "Could not find call: #{id}"
	end

	def user(id)
		id if id.blank?
		@user_lookup[id] or raise "Could not find user: #{id}"
	end

	def user_calls(user_id)
		u = user(user_id)
		calls.find_all { |c| c.users.include? u }
	end

end
