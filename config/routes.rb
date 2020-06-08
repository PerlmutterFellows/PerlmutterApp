Rails.application.routes.draw do
  get 'home/index'
  #devise_scope :user do
  #  root to: "devise/sessions#new"
  #end
  devise_for :users, controllers: {
      sessions: 'users/sessions'
  }, path: '', path_names: { sign_in: 'login', sign_up: 'registration', sign_out: 'logout', confirmation: 'verification'}
  post 'recCall', to: 'twilio#recCall'
  post 'recText', to: 'twilio#recText'
  get 'admin/user/new', to: 'admin#newUser'
  post 'admin/user/create', to: 'admin#createUser'
  get 'admin/event/new', to: 'admin#newEvent'
  get 'admin/event/edit/:id', to: 'admin#editEvent'
  post 'admin/event/modify', to: 'admin#modifyEvent'
  root 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
