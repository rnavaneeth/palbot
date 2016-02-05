require 'firebase'
require 'time'
require 'yaml'

module PalFirebase 
	@firebase_config = YAML.load_file('development.yml')
	def self.post_quotes(quote, user, created_by)
		base_uri = "https://#{@firebase_config['base_uri']}.firebaseio.com/"
		firebase = Firebase::Client.new(base_uri, @firebase_config['secret_key'])

		response = firebase.push("quotes", { 
			:quote => quote.to_s, 
			:created_by => created_by, 
			:user => user, 
			:time => Time.now().to_i 
		})
		response.success? # => true
		p response.success?
		p response.raw_body
		response.code # => 200
		response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
		response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'
	end

def get_quote(key)
end

def method(quote)

end
	
end
