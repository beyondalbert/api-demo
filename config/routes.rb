Rails.application.routes.draw do
	scope(:path => '/v1') do
  	resources :items
  	resources :users

  	post "login" => "sessions#create", :as => "login"
  	post "logout" => "sessions#destroy", :as => "logout"
  	post "captcha", to: "sessions#captcha"
  	post "send_msg_token", to: "sessions#send_msg_token"
  	post "register", to: "users#register"
  	post "reset_password", to: "users#reset_password"
	end
end
