SimpleGallery::Application.routes.draw do

  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login

  resources :sessions
  resources :users
  resources :shares do
    collection do
      get "bulk_add"
      post "bulk_update"
    end
  end
  get "photos/:hash.jpg", to: "photos#shared", as: "photo_share"
  post "photos/upload"
  get "photos/ajax_year"
  resources :photos

  root to: "photos#index"
end
