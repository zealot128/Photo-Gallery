SimpleGallery::Application.routes.draw do

  get "pages/index"

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
    member do
      post "remove_image"
    end
  end
  get "photos/:hash.jpg", to: "photos#shared", as: "photo_share"
  post "photos/upload"
  get "photos/ajax_year"
  get "photos/ajax_photos"
  resources :photos

  root to: "pages#index"
end
