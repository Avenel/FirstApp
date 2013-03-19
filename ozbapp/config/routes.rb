OZB::Application.routes.draw do
  devise_for :OZBPerson, :path_names => { :sign_up => "Registration", :sign_in => "Anmeldung" }
  get "willkommen/index"
  
  match '/'				=> 'willkommen#index'
  match '/MeineKonten' 	=> 'willkommen#index'
  


### Konten
  match '/Darlehensverlauf/:KtoNr/:EEoZEkonto' => 'darlehensverlauf#new'
  match '/Darlehensverlauf/:ktoNr/:EEoZEkonto/:name/:vName/:vonDat/:bisDat/ktoAuszug' => 'darlehensverlauf#kontoauszug'
  match '/Verwaltung/OZBPerson/:Mnr/Konten'                           => 'ozb_konto#index',             :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Konten/:kontotyp/Neu'             => 'ozb_konto#new',               :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Konten/:kontotyp/Neu'             => 'ozb_konto#create',            :via => :POST
  match '/Verwaltung/OZBPerson/:Mnr/Konten/:kontotyp/:KtoNr/Aendern'  => 'ozb_konto#edit',              :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Konten/:kontotyp/:KtoNr/Aendern'  => 'ozb_konto#update',            :via => :PUT
  match '/Verwaltung/OZBPerson/:Mnr/Konten/:kontotyp/:KtoNr/Loeschen' => 'ozb_konto#delete',            :via => :POST
  match '/Verwaltung/OZBPerson/:Mnr/Konten/:KtoNr/KKLVerlauf'         => 'ozb_konto#verlauf',           :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Konten/:KtoNr/Kontoauszug'        => 'ozb_konto#account_statement', :via => :GET
  
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften'                    => 'buergschaft#index',           :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/Neu'                => 'buergschaft#new',             :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/Neu'                => 'buergschaft#create',          :via => :POST
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/:Pnr_B/Aendern'     => 'buergschaft#edit',            :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/:Pnr_B/Aendern'     => 'buergschaft#update',          :via => :PUT
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/:Pnr_B/Loeschen'    => 'buergschaft#delete',          :via => :POST

  match '/MeineDaten'				=> 'o_z_b_person#detailsOZBPerson'
  match '/MeineDaten/Details' 		=> 'o_z_b_person#detailsOZBPerson'
  
  match '/MeineDaten/Personaldaten' => 'o_z_b_person#editPersonaldaten', :via => :GET
  match '/MeineDaten/Personaldaten' => 'o_z_b_person#updatePersonaldaten', :via => :POST

  match '/MeineDaten/Kontaktdaten' => 'o_z_b_person#editKontaktdaten', :via => :GET
  match '/MeineDaten/Kontaktdaten' => 'o_z_b_person#updateKontaktdaten', :via => :POST

  match '/MeineDaten/Rolle' => 'o_z_b_person#editRolle', :via => :GET
  match '/MeineDaten/Rolle' => 'o_z_b_person#updateRolle', :via => :POST

  match '/MeineDaten/Logindaten' => 'o_z_b_person#editLogindaten', :via => :GET
  match '/MeineDaten/Logindaten' => 'o_z_b_person#updateLogindaten', :via => :POST
  
  
  
  
  #neu Hinzugefuegte Routes##
  match '/Verwaltung/Rollen'                        => 'sonderberechtigung#editRollen'
  match '/Verwaltung/Geschaeftsprozesse'            => 'sonderberechtigung#listGeschaeftsprozesse', :via => :GET
  match '/Verwaltung/Geschaeftsprozesse'            => 'sonderberechtigung#createGeschaeftsprozess', :via => :POST
  match '/Verwaltung/Rollen/NeueSonderberechtigung' => 'sonderberechtigung#createSonderberechtigung'
  
  match '/Verwaltung/Veranstaltungen/:Vnr/Ansicht'        => 'veranstaltung#listVeranstaltung', :via => :GET
  match '/Verwaltung/Veranstaltungen/:Vnr/Ansicht'        => 'veranstaltung#createDeleteTeilnahme', :via => :POST
  match '/Verwaltung/Veranstaltungen'                     => 'veranstaltung#editVeranstaltungen', :via => :GET
  match '/Verwaltung/Veranstaltungen'                     => 'veranstaltung#createVeranstaltung', :via => :POST
  
  
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/:Pnr_B/AendernB'      => 'buergschaft#editB',            :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/:Pnr_B/AendernB'      => 'buergschaft#updateB',          :via => :PUT
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/:Pnr_B/LoeschenB'     => 'buergschaft#deleteB',          :via => :POST
  match '/Verwaltung/OZBPerson/:Mnr/Buergschaften/AeltereBuergschaften' => 'buergschaft#listHisto'
  
  match '/Verwaltung/editRollen' => 'sonderberechtigung#editBerechtigungenRollen', :via => :GET
  match '/Verwaltung/editRollen' => 'sonderberechtigung#createBerechtigungRollen', :via => :POST
  
  match '/Verwaltung/OZBPerson/:Mnr/Teilnahmen' => 'veranstaltung#listTeilnahmen'
  
  match '/Verwaltung/Darlehensvertrag' => 'darlehensvertrag#new'
  match '/Verwaltung/Darlehensvertrag/BerechnungsFormular' => 'darlehensvertrag#anzeigen'
  match '/Verwaltung/Darlehensvertrag/BerechnungsFormular/Berechnet' => 'darlehensvertrag#berechnen'


  #bis hier
  
  ####noch neuer###
  
   match '/Verwaltung/Veranstaltungen/NeueVeranstaltung'                     => 'veranstaltung#newVeranstaltung', :via => :GET
   
   
   ###09.03.2013###
   
  match "dynamic_districts/:id" => "buergschaft#dynamic_districts", :via => :POST

  
  
  
  
  #bis hier
 

### Verwaltung
  match '/Verwaltung/OZBPerson/NeuePerson' => 'verwaltung#newOZBPerson'
  match '/Verwaltung/OZBPerson/NeuePerson/Speichern' => 'verwaltung#createOZBPerson', :via => :POST

  match '/Verwaltung/Mitglieder'              => 'verwaltung#listOZBPersonen'
  match '/Verwaltung/Mitglieder/Suchen'       => 'verwaltung#searchOZBPerson' #NU
  match '/Verwaltung/WebImport'               => 'webimport#index', :via => :GET
  match '/Verwaltung/WebImport/Buchungen'     => 'webimport#csvimport_buchungen', :via => :POST
  
  match '/Verwaltung/OZBPerson/:Mnr/Details' => 'verwaltung#detailsOZBPerson', :via => :GET
  
  match '/Verwaltung/OZBPerson/:Mnr/Personaldaten' => 'verwaltung#editPersonaldaten', :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Personaldaten' => 'verwaltung#updatePersonaldaten', :via => :POST
 
  match '/Verwaltung/OZBPerson/:Mnr/Kontaktdaten' => 'verwaltung#editKontaktdaten', :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Kontaktdaten' => 'verwaltung#updateKontaktdaten', :via => :POST
  
  match '/Verwaltung/OZBPerson/:Mnr/Rollen' => 'verwaltung#editRolle', :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Rollen' => 'verwaltung#updateRolle', :via => :POST
  
  match '/Verwaltung/OZBPerson/:Mnr/Sonderberechtigungen' => 'verwaltung#editBerechtigungen', :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Sonderberechtigungen' => 'verwaltung#createBerechtigung', :via => :POST
  
  match '/Verwaltung/OZBPerson/:Mnr/Sonderberechtigung/:id/Loeschen' => 'verwaltung#deleteBerechtigung', :via => :GET
  match '/Verwaltung/OZBPerson/:Mnr/Loeschen' => 'verwaltung#deleteOZBPerson', :via => :GET
  
  # Application
  match '/application/suche_ozb_personen.js' => 'application#searchOZBPerson'

  # root
  root :to => 'willkommen#index'



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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
