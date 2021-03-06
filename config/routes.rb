Rails.application.routes.draw do

  resources :owners

  resources :shipment_statuses

  resources :shipments do
    member do
      post 'create_shipment_status'
    end
  end

  devise_for :users, :path_names => {sign_in: "login", sign_out: "logout"} do
    # devise/registrations
    get 'signup' => 'devise/registrations#new', :as => :new_user_registration
    post 'signup' => 'devise/registrations#create', :as => :user_registration
    get 'users/cancel' => 'devise/registrations#cancel', :as => :cancel_user_registration
    get 'users/edit' => 'devise/registrations#edit', :as => :edit_user_registration
    put 'users' => 'devise/registrations#update'
    delete 'users/cancel' => 'devise/registrations#destroy'  
    # devise/sessions
    get 'login' => 'devise/sessions#new', :as => :new_user_session
    post 'login' => 'devise/sessions#create', :as => :user_session
    delete 'users/logout' => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  get 'dash', to: 'vessels#dash', :as => :dash
  get 'non_russian', to: 'vessels#non_russian', :as => :non_russian

  resources :positions
  resources :vessels do
    collection do
      get :dash
      get :maps
      get :non_russian
      get :scan
      get :scan_gps
      post :engage
    end
  end

  get 'about', to: 'static_pages#about'
  
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: 'vessels#dash'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
