Masq::Engine.routes.draw do
  resource :account do
    resources :personas
    resources :sites
    resource :yubikey_association, :only => [:create, :destroy]
  end

  get "/help" => "info#help", :as => :help
  get "/safe-login" => "info#safe_login", :as => :safe_login

  match "/server" => "server#index", :as => :server
  match "/server/decide" => "server#decide", :as => :decide
  match "/server/proceed" => "server#proceed", :as => :proceed
  match "/server/complete" => "server#complete", :as => :complete
  match "/server/cancel" => "server#cancel", :as => :cancel
  get "/server/seatbelt/config.:format" => "server#seatbelt_config", :as => :seatbelt_config
  get "/server/seatbelt/state.:format" => "server#seatbelt_login_state", :as => :seatbelt_state

  get "/consumer" => "consumer#index", :as => :consumer
  post "/consumer/start" => "consumer#start", :as => :consumer_start
  match "/consumer/complete" => "consumer#complete", :as => :consumer_complete

  get "/*account" => "accounts#show", :as => :identity

  root :to => "info#index"
end
