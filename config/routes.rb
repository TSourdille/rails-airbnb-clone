Rails.application.routes.draw do
  mount Attachinary::Engine => "/attachinary"
  devise_for :users,
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root to: 'pages#home'
  resources :boats, only: [:index, :show, :new, :create] do
    resources :bookings, only: [:new, :create, :update]
  end
end
