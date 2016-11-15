Rails.application.routes.draw do
  get 'boats/new'

  devise_for :users
  root to: 'pages#home'
  resources :boats, only: [:new, :create]
end
