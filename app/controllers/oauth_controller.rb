class OauthController < ApplicationController

	def redirect
	  session[:access_token] = Koala::Facebook::OAuth.new('http://giftique.herokuapp.com/oauth').get_access_token(params[:code]) if params[:code]

	  redirect_to session[:access_token] ? 'home#index' : '/fberror.html', :notice => "Successful FB Authorization"
	end
end
