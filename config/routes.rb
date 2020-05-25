Rails.application.routes.draw do
  devise_for :users, controllers: {
      sessions: 'users/sessions'
  }, path: '', path_names: { sign_in: 'login', sign_up: 'registration', sign_out: 'logout', confirmation: 'verification'}

  root 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
