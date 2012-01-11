OZB::Application.routes.draw do
  
  # Devise - Login Management
  devise_for :OZBPerson
  
  # OZBPerson
  match '/OZBPerson' => 'OZBPerson#index'
  match '/OZBPerson/new' => 'OZBPerson#new'
  match '/OZBPerson/new' => 'OZBPerson#searchOZBPerson'
  match '/OZBPerson/save' => 'OZBPerson#create'
	match '/OZBPerson/:id' => 'OZBPerson#edit', :via => :GET
	match '/OZBPerson/:id' => 'OZBPerson#update', :via => :POST  
  match '/OZBPerson/:id/delete' => 'OZBPerson#delete'
  match '/OZBPerson/:id/Konto' => 'OzbKonto#index'
  match '/OZBPerson/:id/Konto/:typ/new' => 'OzbKonto#new'
  match '/buergschaften/Konto/:typ/new' => 'OzbKonto#searchKtoNr'
  match '/OZBPerson/:id/Konto/:typ' => 'OzbKonto#create', :via => :POST
  match '/OZBPerson/:id/Konto/:typ/:ktoNr' => 'OzbKonto#edit', :via => :GET
  match '/OZBPerson/:id/Konto/:typ/:ktoNr' => 'OzbKonto#update', :via => :POST
  match '/OZBPerson/:id/Konto/:typ/:ktoNr/delete' => 'OzbKonto#delete'
  match '/OZBPerson/:id/Konto/:typ/:ktoNr/buchungen' => 'OzbKonto#show', :via => :GET
  match '/OZBPerson/:id/Daten' => 'index#error_404'
  
  # Tanlisten
  match '/OZBPerson/:id/Tanlisten' => "index#error_404"
  
  # Kontenklassen
  match '/kontenklasse' => 'kontenklasse#index'
  match '/kontenklasse/new' => 'kontenklasse#new'
  match '/kontenklasse/save' => 'kontenklasse#create'
  match '/kontenklasse/:id' => 'kontenklasse#edit', :via => :GET
  match '/kontenklasse/:id' => 'kontenklasse#update', :via => :POST
  match '/kontenklasse/:id/delete' => 'kontenklasse#delete'
  
  # OZBKonten
  match '/ozbKonten' => 'reports#ozbKonten'
  
  # KKL
  match '/ozbKonten/KKL' => 'OzbKonto#kkl', :via => :GET
  match '/ozbKonten/KKL' => 'OzbKonto#changeKKL', :via => :POST
  match '/ozbKonten/KKL' => 'OzbKonto#searchKtoNr'
  
  # Buergschaften
  match '/buergschaften' => 'buergschaft#index'
  match '/buergschaften/new' => 'buergschaft#new'
  match '/buergschaften/new' => 'buergschaft#searchKtoNr'
  match '/buergschaften/new' => 'buergschaft#searchOZBPerson'
  match '/buergschaften/save' => 'buergschaft#create'
  match '/buergschaften/:pnrB/:mnrG' => 'buergschaft#edit', :via => :GET
  match '/buergschaften/:pnrB/:mnrG' => 'buergschaft#update', :via => :POST
  match '/buergschaften/:pnrB/:mnrG/delete' => 'buergschaft#delete'
  
  # Adressen
  match '/adressen' => 'reports#adressen'
  
  # Application
  match '/application/suche_ozb_personen.js' => 'application#searchOZBPerson'
  match '/application/suche_konten.js' => 'application#searchKtoNr'
  
  # Administration
  match '/Admin' => "index#admin"
  
  # Protokolle
  match '/Protokolle' => "index#error_404"
  
  # OzBlick
  match '/OzBlick' => "index#error_404"
  

  
  # Root
  root :to => "index#dashboard"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
