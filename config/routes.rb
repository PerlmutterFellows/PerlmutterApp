Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
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
      get 'users', action: 'index', controller: 'users/registrations'
      get 'users/new', action: 'new_by_admin', controller: 'users/registrations'
      get 'users/create', action: 'new_by_admin', controller: 'users/registrations'
      post 'users/create', action: 'create_by_admin', controller: 'users/registrations'
      delete 'users/delete/:id', action: 'delete', controller: 'users/registrations', as: 'users_delete'
      get 'users/:id', action: 'show', controller: 'users/registrations', as: 'users_show'
    end
    devise_for :users, controllers: {
        sessions: 'users/sessions'
    }, path: '', path_names: { sign_in: 'login', sign_up: 'registration', sign_out: 'logout', confirmation: 'verification'}
    post 'receive_call', to: 'twilio#receive_call'
    post 'receive_text', to: 'twilio#receive_text'
    get 'form', action: 'form', controller: 'static_pages'
    post 'form', action: 'results', controller: 'static_pages', as: 'form_results'
    get 'faq', action: 'faq', controller: 'static_pages'
    get 'contact', action: 'contact', controller: 'static_pages'
    post 'contact', action: 'contact_send', controller: 'static_pages'
    root 'static_pages#home'
    get "/404", :to => redirect { '/' }
    # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  end
end
