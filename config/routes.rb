Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # LINE認証（統一）
  get "/auth/line/callback", to: "sessions#create"
  post "/auth/line/callback", to: "sessions#create"
  post "/line_sessions", to: "line_sessions#create"
  delete "/logout", to: "sessions#destroy"

  # LINE誘導ページ
  get "/line_guide", to: "line_guides#show"

  # 静的ページ
  root "static_pages#top"
  get "how_to_use", to: "static_pages#how_to_use"
  get "terms", to: "static_pages#terms"
  get "contact", to: "static_pages#contact"
  get "privacy", to: "static_pages#privacy"

  # google form用
  get "forms/custom_form", to: "forms#custom_form"
  get "forms/thanks", to: "forms#thanks"

  resources :plants, only: [ :index, :update ]

  resources :checkinout_records, only: [ :edit ] do
    collection do
      get :checkin_page, as: :checkin
      post :checkin
      get :checkout_page, as: :checkout
      patch :checkout
    end

    resources :moods, only: [ :create ] do
      collection do
        get :mood_check
      end
    end
  end

  resource :mypage, only: [ :show ]
  get "/checkinout_records/mypage", to: "mypage#show", as: "mypage_checkinout_records"

  resources :moods, only: [] do
    collection do
      get :analytics
    end
  end
end
