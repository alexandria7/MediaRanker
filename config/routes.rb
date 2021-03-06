Rails.application.routes.draw do
  root to: "homepages#index"
  get "homepages/index"
  resources :works

  resources :works do
    member do
      post "upvote" #upvote_work_path
    end
  end

  get "/login", to: "users#login_form", as: "login"
  post "/login", to: "users#login"
  post "/logout", to: "users#logout", as: "logout"
  get "/users/current", to: "users#current", as: "current_user"

  resources :users, only: [:index, :show]
end
