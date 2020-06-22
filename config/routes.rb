Rails.application.routes.draw do
  resources :groups
  resources :events do
    member do
      get :attend
      post :attend
    end
    member do
      get :unattend
      post :unattend
    end
  end
  get 'home/index'
  devise_scope :user do
    get 'users/new', action: 'new_by_admin', controller: 'users/registrations'
    get 'users/create', action: 'new_by_admin', controller: 'users/registrations'
    post 'users/create', action: 'create_by_admin', controller: 'users/registrations'
  end
  devise_for :users, controllers: {
      sessions: 'users/sessions'
  }, path: '', path_names: { sign_in: 'login', sign_up: 'registration', sign_out: 'logout', confirmation: 'verification'}
  post 'receive_call', to: 'twilio#receive_call'
  post 'receive_text', to: 'twilio#receive_text'
  root 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
