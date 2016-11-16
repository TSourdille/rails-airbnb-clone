Rails.application.routes.draw do
  get 'users/show'

  get 'users/new'

  get 'users/create'

  mount Attachinary::Engine => "/attachinary"
  devise_for :users,
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root to: 'pages#home'
  resources :users, only: [:show]
  resources :boats, only: [:index, :show, :new, :create] do
    resources :bookings, only: [:new, :create, :update]
  end

end
