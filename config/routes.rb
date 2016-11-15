Rails.application.routes.draw do
  mount Attachinary::Engine => "/attachinary"
  root to: 'pages#home'
  devise_for :users
  resources :boats, only: [:new, :create]
end
