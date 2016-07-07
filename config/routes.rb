SimpleGallery::Application.routes.draw do

  # Api compliance for Photobackup
  post '/test' => 'upload#test'

  get 'pages/index'

  get 'user/edit' => 'users#edit', :as => :edit_current_user
  get 'signup' => 'users#new', :as => :signup
  delete 'logout' => 'sessions#destroy', :as => :logout
  get 'login' => 'sessions#new', :as => :login

  resources :sessions
  resources :users
  resources :shares do
    member do
      post 'remove_image'
    end
  end

  get "download/:id/:filename" => 'photos#download', filename: /.*/

  namespace :admin do
    get 'upload_logs' => 'upload_logs#index'
    get 'aws_statistics' => 'upload_logs#aws'
    match 'already_uploaded' => 'misc#already_uploaded', via: [:get, :post]
  end

  namespace :v2 do
    resources :years, only: [:index, :show] do
      collection do
        get 'recent'
      end
      member do
        get 'month/:month' => 'months#show', as: :month
      end
    end
    resources :days, only: [:show]
    get 'tags' => 'api#tags'
    get 'shares' => 'api#shares'
    post 'bulk_update' => 'api#bulk_update'
  end
  get '/shares/:id/download' => 'zip#share', as: 'download_share'
  get 'photos/:hash.jpg', to: 'photos#shared', as: 'photo_share'

  get 'api/exists' => 'upload#exists'

  post 'photos/upload'
  post 'upload/:token' => 'upload#create', as: :token_upload
  post 'photos' => 'upload#create'
  get 'photos' => 'v2/years#index'
  resources :photos do
    member do
      post :rotate
      post :ocr
    end
  end
  get 'tag/:id',  to: 'pages#tag', as: 'pages_tag'
  get 'upload' => 'pages#upload'

  get '/', to: 'pages#index', as: 'root'
  post '/', to: 'upload#create'
end
