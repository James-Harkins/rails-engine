Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      namespace :items do
        resources :find, only: [:index]
      end

      namespace :merchants do
        resources :find_all, only: [:index]
      end

      resources :items, only: [:index, :show, :create, :update, :destroy] do
        get "/merchant", to: "item_merchant#index"
      end

      resources :merchants, only: [:index, :show] do
        get "/items", to: "merchant_items#index"
      end
    end
  end
end
