require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
load 'test.rb'  
 configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] ||= 'super secret'
end
# Handle GET-request (Show the upload form)
get "/" do
	noSolutions = false
	if session[:do]
		if not flash[:notice]
			if session[:fname2] and File.exist?("uploads/#{session[:fname]}") and File.exist?("uploads/#{session[:fname2]}")
				@package = Setup.new.parse(session[:fname],session[:fname2],session.has_key?(:gender),session.has_key?(:good_ratio),params[:min],params[:max])
				File.delete("uploads/#{session[:fname2]}")
				File.delete("uploads/#{session[:fname]}")
			elsif File.exist?("uploads/#{session[:fname]}")
				@package = Setup.new.parse(session[:fname],nil,session.has_key?(:gender),session.has_key?(:good_ratio),params[:min],params[:max])
				File.delete("uploads/#{session[:fname]}")
			end
		end
		session[:do] = nil
	end
	
    erb :upload
end    

# Handle POST-request (Receive and save the uploaded file)
post "/" do
	if params[:gender]
		session[:gender] = "on"
	end
	if params[:good_ratio]
		session[:good_ratio] = "on"
	end
	if params['myfile']
		if not params['myfile'][:filename].end_with? ".txt"
			flash[:notice] = "Please upload .txt files"
		else
			session[:fname] = params['myfile'][:filename]
			File.open('uploads/' + params['myfile'][:filename], "w") do |f|
				f.write(params['myfile'][:tempfile].read)
			end
		end

		if params['myfile2']
			if not params['myfile2'][:filename].end_with? ".txt"
				flash[:notice] = "Please upload .txt files"
			else
				session[:fname2] = params['myfile2'][:filename]
				File.open('uploads/' + params['myfile2'][:filename], "w") do |f|
					f.write(params['myfile2'][:tempfile].read)
				end
			end	
		end
	else
		flash[:notice] = "Please upload a file"
	end

  	session[:do] = true
  
	redirect '/'
end

get '/clear' do
	session.clear
end

get "/special" do
	"#{session[:gender]},#{session[:good_ratio]}"
end

get "/special2" do
	"hello #{session[:data]}"
end