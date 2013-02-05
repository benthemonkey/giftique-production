class OauthController < ApplicationController

	def redirect
	  session[:access_token] = Koala::Facebook::OAuth.new(ENV["FB_CALLBACK_URL"]+'oauth').get_access_token(params[:code]) if params[:code]

	  redirect_to session[:access_token] ? '/#index' : '/fberror.html', :notice => "Successful FB Authorization"
	end
end
