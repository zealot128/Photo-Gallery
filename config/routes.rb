SimpleGallery::Application.routes.draw do

  get 'pages/index'

  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login

  resources :sessions
  resources :users
  resources :shares do
    collection do
      get 'bulk_add'
      post 'bulk_update'
    end
    member do
      post 'remove_image'
    end
  end
  get '/shares/:id/download' => 'zip#share', as: 'download_share'
  get 'photos/:hash.jpg', to: 'photos#shared', as: 'photo_share'
  post 'photos/upload'
  get 'photos/ajax_year'
  get 'photos/ajax_photos'
  resources :photos do
    member do
      post :rotate
      post :ocr
    end
  end
  get 'tag/:id',  to: 'pages#tag', as: 'pages_tag'

  get '/', to: 'pages#index', as: 'root'
  post '/', to: 'photos#create'
end
