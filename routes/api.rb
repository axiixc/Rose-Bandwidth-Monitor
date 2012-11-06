helpers do
	def api_user(username)
		username ||= 'savagejs'
		Rose::User.first(:username => username) || halt(404)
	end
end

get '/api/info/?' do
	{
		info: api_user.api_representation(:full)
	}.to_json
end

get '/api/:username/devices/?' do |username|
	{
		devices: Rose::Device.api_representation(api_user(username))
	}.to_json
end

get '/api/:username/usage/?' do |username|
	user = api_user(username)
	
	{
		devices: Rose::Device.api_representation(user),
		entries: Rose::BandwidthEntry.api_representation(user)
	}.to_json
end

get '/api/:username/usage_summary/?' do |username|
	user = api_user(username)
	
	{
		info: user.api_representation(:summary),
		devices: Rose::Device.api_representation(user),
		entries: Rose::BandwidthEntry.api_representation(user)
	}.to_json
end