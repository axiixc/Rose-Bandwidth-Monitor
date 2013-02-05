helpers do
	def api_user(token = nil)
		token || halt(404)
		
		user = Rose::User.first(:username => token, :public_stats => true)
		type = :username if !user.nil?
		
		if user.nil?
			user = Rose::User.first(:protected_stats_token => token)
			type = :api_token if !user.nil?
		end
		
		[ user || halt(404), type ]
	end
end

# This endpoint adds support for @session_user, to override public stats blocks
get '/_api/:token/report/?' do |token|
	params.delete!('scrape_first') if params.include?('scrape_first') && @session_user.username != token
	
	profile_user = (!@session_user.nil? && @session_user.username == token) ? @session_user :
		Rose::User.first(:username => token, :public_stats => true)
	profile_user ||= Rose::User.first(:protected_stats_token => token)
	
	halt(404) if profile_user.nil?
	
	content_type :json
	payload = params.include?('scrape_first') ? profile_user.scrape :	profile_user.report_with_name(:basic)
	payload[:metadata][:last_scrape] = profile_user.current_usage.data_age
	
	payload.to_json
end

get '/api/userlist' do
	content_type :json
	{
		users: Rose::User.api_representation
	}.to_json
end

get '/api/:token/info/?' do |token|
	user, type = api_user(token)
	
	content_type :json
	{
		info: user.api_representation((type == :api_token) ? :full : :minimal)
	}.to_json
end

get '/api/:token/devices/?' do |token|
	user, type = api_user(token)
	
	content_type :json
	{
		devices: Rose::Device.api_representation(user)
	}.to_json
end

get '/api/:token/usage/?' do |token|
	user, type = api_user(token)
	
	user.scrape if params.include?('scrape_first') && type == :api_token
	
	content_type :json
	{
		devices: Rose::Device.api_representation(user),
		entries: Rose::BandwidthEntry.api_representation(user)
	}.to_json
end

get '/api/:token/summary/?' do |token|
	user, type = api_user(token)
	
	content_type :json
	{
		info: user.api_representation((type == :api_token) ? :full : :minimal),
		devices: Rose::Device.api_representation(user),
		entries: Rose::BandwidthEntry.api_representation(user)
	}.to_json
end