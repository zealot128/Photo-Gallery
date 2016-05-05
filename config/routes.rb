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
    collection do
      get 'bulk_add'
      post 'bulk_update'
    end
    member do
      post 'remove_image'
    end
  end

  get "download/:id/:filename" => 'photos#download', filename: /.*/

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
  end
  get '/shares/:id/download' => 'zip#share', as: 'download_share'
  get 'photos/:hash.jpg', to: 'photos#shared', as: 'photo_share'

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

  get '/', to: 'pages#index', as: 'root'
  post '/', to: 'upload#create'
end
