require 'net/http'

require 'rubygems'
require 'json'

class CreateWebhooks

	@@host = "https://api.github.com"
	@@port = 443
	
	def post(organization,student,reponame,user,pass,url)

	payload ='{
	  "name": "web",
	  "active": true,
	  "events": ["push"],
	  "config": {
	    "url": "' + url + '",
	    "content_type": "json"
	  }
	}'	

		post_url = @@host + "/repos/" + organization + "/" + student + "-" + reponame + "/hooks"
		uri = URI(post_url)

		Net::HTTP.start(uri.host,uri.port,
			:use_ssl => uri.scheme = 'https') do |http|
			request = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
	          	request.basic_auth user, pass
	          	request.body = payload
	          	http.request request do |response|
	          		response.read_body do |chunk|
	          			puts chunk
	          		end
	          	end
	        end
	end
end