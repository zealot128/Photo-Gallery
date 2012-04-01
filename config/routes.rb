SimpleGallery::Application.routes.draw do

  get "photos/:hash.jpg", to: "photos#shared", as: "photo_share"
  resources :photos

  root to: "photos#index"
end
