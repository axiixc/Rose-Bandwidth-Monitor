helpers do
	def api_user(token = nil)
		token || halt(404)
		
		user = Rose::User.first(:username => token, :public_stats => true)
		user ||= Rose::User.first(:protected_stats_token => token)
		
		user || halt(404)
	end
end

# This endpoint adds support for @session_user, to override public stats blocks
get '/_api/:token/report/?' do |token|
	halt(401) if params.include?('scrape_first') && @session_user.username != token
	
	profile_user = (!@session_user.nil? && @session_user.username == token) ? @session_user :
		Rose::User.first(:username => token, :public_stats => true)
	profile_user ||= Rose::User.first(:protected_stats_token => token)
	
	halt(404) if profile_user.nil?
	
	content_type :json
	(params.include?('scrape_first') ?
		profile_user.scrape :
		profile_user.report_with_name(:basic)
	).to_json
end

get '/api/:token/info/?' do |token|
	content_type :json
	
	if !(user = Rose::User.first(:username => token, :public_stats => true)).nil?
		return { info: user.api_representation(:summary) }.to_json
		
	elsif !(user = Rose::User.first(:protected_stats_token => token)).nil?
		return { info: user.api_representation(:full) }.to_json
	end
	
	halt(401)
end

get '/api/:token/devices/?' do |token|
	content_type :json
	{
		devices: Rose::Device.api_representation(api_user(token))
	}.to_json
end

get '/api/:token/usage/?' do |token|
	user = api_user(token)
	
	content_type :json
	{
		devices: Rose::Device.api_representation(user),
		entries: Rose::BandwidthEntry.api_representation(user)
	}.to_json
end

get '/api/:token/summary/?' do |token|
	user = api_user(token)
	
	content_type :json
	{
		info: user.api_representation(:summary),
		devices: Rose::Device.api_representation(user),
		entries: Rose::BandwidthEntry.api_representation(user)
	}.to_json
end