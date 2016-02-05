require 'slack-ruby-bot'
require_relative 'pal_firebase'
require 'yaml'

SlackRubyBot.configure do |config|
  config.aliases = [':pal:', 'pal', 'palquote']
end

class PalBot < SlackRubyBot::Bot
	include PalFirebase
	@config = YAML.load_file('development.yml')
	match /^.*$/ do |client, data, match|
		#p "channel: #{client.channels}"
		channels = @config['allowed_channels']
		allowed_channels = []
		channels.each{|channel_name| client.channels.find{|k,v| allowed_channels << k if v['name']==channel_name}}
		p "Allowed: #{allowed_channels}"
		if allowed_channels.include?(data.channel)
			created_by = client.users[data['user']]
			said_by = data['text'].scan(/by <@\w+>/).first
			data['text'].gsub(said_by, '') if said_by
			word_map = data['text'].split.drop(1)
			
			new_word_map = word_map.map do |word| 
				p "Before Word: #{word}"
				match = word.scan(/<@(\w+)>/).flatten.first
				p "Match: #{match}"
				if match
					client.users[match]['name'] 
				else
					word
				end
			end	
			quote = new_word_map.join(" ")

			if said_by
				user = client.users[said_by.scan(/<@(\w+)>/).flatten.first] 
			end
			user ||= {
				name: 'Unknown'
			}
			PalFirebase::post_quotes(quote, user, created_by)
			client.say(text: client.class, channel: data.channel)
		end
	end

	# command 'hi hi hi' do |client, data, match|
		# client.say(text: "yoyo", channel: data.channel)
	# end
end

class Responder < SlackRubyBot::Commands::Base
	quotes_map = {
					'update'=> 'BlackOps is good',
					'joker'=> 'I am fixing bugs. How can a joker fix bugs??? I am serious',
					'production'=> ':crying_cat_face:',
					'travel'=> 'I used to go 60kms up and down',
					'sweet'=> 'Gujrathi guys are sweet guys',
					'hi'=> 'What man?' 
				 }


	def value(sentence)
		key = sentence.split.find{|x| quotes_map.has_key? x}
		quotes_map[key]
	end

	def self.call(client, data, match)
		caller = ::User.find_create_or_update_by_slack_id!(client, data.user)
        key = sentence.split.find{|x| quotes_map.has_key? x}		
		statement = key.nil? ? "I don't understand waat you are talking man" : quotes_map[key]
        client.say(channel: data.channel, text: "Dai #{caller}! #{statement}")
        logger.info "Responder: Response for #{sentence}"
	end
end



PalBot.run