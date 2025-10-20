Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "static_pages#top"
  get "how_to_use", to: "static_pages#how_to_use"
  get "terms", to: "static_pages#terms"
  get "contact", to: "static_pages#contact"
  get "privacy", to: "static_pages#privacy"

  resources :checkinout_records, only: [ :index, :show, :edit ] do
    collection do
      get :checkin_page
      get :edit_today
      get :checkout_page
      get :mood_record
      get :mypage
      post :checkin
      patch :checkout
    end

    resources :moods, only: [ :create ] do
      collection do
        get :mood_check
      end
    end
  end

  resources :moods, only: [] do
    collection do
      get :analytics
    end
  end

  get "/checkin", to: "checkinout_records#smart_checkin"
  get "/checkout", to: "checkinout_records#smart_checkout"
end
