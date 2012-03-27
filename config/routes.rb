SimpleGallery::Application.routes.draw do
  devise_for :users

  resource :photos

  root to: "photos#index"
end
