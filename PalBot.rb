require 'slack-ruby-bot'
require_relative 'pal_firebase'

SlackRubyBot.configure do |config|
  config.aliases = [':pal:', 'pal', 'palquote']
end

class PalBot < SlackRubyBot::Bot
	include PalFirebase

	match /^.*$/ do |client, data, match|
		created_by = client.users[data['user']]
		said_by = data['text'].scan(/by <@\w+>/).first		
		quote = data['text'].gsub(said_by, '').split.drop(1).join(" ")
		said_by = said_by.scan(/<@(\w+)>/).flatten.first
		PalFirebase::post_quotes(quote, client.users[said_by], created_by)
		client.say(text: client.class, channel: data.channel)
	end
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