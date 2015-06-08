Rails.application.routes.draw do
  root 'welcome#index'
  resources :users, only: [:show]
  get '/soundcloud/connect' => 'soundcloud#connect', :as => :soundcloud_connect
  get '/soundcloud/connected' => 'soundcloud#connected', :as => :soundcloud_connected
  get '/soundcloud/disconnect' => 'soundcloud#disconnect', :as => :soundcloud_disconnect
  get '/streams/popular' => 'streams#popular', :as => :popular
  get '/streams/random' => 'streams#random', :as => :random
  get '/streams/recent' => 'streams#recent', :as => :recent
end
