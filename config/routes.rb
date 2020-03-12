Rails.application.routes.draw do
  resources :profiles
  resources :rides

  devise_for :users, controllers: { registrations: 'users/registrations' }

  devise_scope :user do
    root to: 'rides#index'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
