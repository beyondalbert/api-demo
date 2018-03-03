Rails.application.routes.draw do
  resources :items
  resources :users

  post "login" => "sessions#create", :as => "login"
  post "logout" => "sessions#destroy", :as => "logout"
  post "captcha", to: "sessions#captcha"
  post "send_msg_token", to: "sessions#send_msg_token"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
