Rails.application.routes.draw do
	get '/about', controller: 'news', action: 'about'
	get '/privacy', controller: 'news', action: 'privacy'
	
	resources :dungeons do
		get 'json/normal' => "dungeons#get_normal_dungeons", on: :collection
		get 'json/special' => "dungeons#get_special_dungeons", on: :collection 
		get 'json/technical' => "dungeons#get_technical_dungeons", on: :collection 
		get 'json/multiplayer' => "dungeons#get_multiplayer_dungeons", on: :collection
	end
	
	resources :ml_ratings, only: [:create]
	
	resources :monster_links
	
    resources :news

	resources :c_ratings, except: [:edit, :update, :destroy, :new, :show]
	resources :c_ll_ratings, except: [:edit, :update, :destroy, :new, :show]
		
	resources :comments,  except: [:edit, :update, :new, :show]
	resources :comment_lls,  except: [:edit, :update, :new, :show]

	resources :votes, except: [:edit, :update, :destroy, :new] do
		get 'statistics' , controller: 'votes', action: 'statistics', on: :collection 
	end
	resources :vote_lls, except: [:edit, :update, :destroy, :new]

	resources :monsters, except: [:destroy, :new, :create, :update, :edit] do
		get 'json/tags', controller: 'monsters', action: 'tags_json', on: :collection 
		get 'json/typeahead', controller: 'monsters', action: 'typeahead_json', on: :collection 
		get 'json/subs/:id', controller: 'monsters', action: 'subs_json', on: :collection 
		#get 'json/id' ,  controller: 'monsters', action: 'idlookup_json', on: :collection
		get 'json/graph', controller: 'monsters', action: 'graph_json', on: :collection
		get 'detail' , controller: 'monsters', action: 'detail', on: :collection 
		get 'tag', controller: 'monsters', action: 'add_tag'
		get 'tag/pair', controller: 'monsters', action: 'add_pair_tag'
		get 'tags', controller: 'monsters', action: 'search', on: :collection
		get 'tags/update', controller: 'monsters', action: 'tag_update', on: :collection
		get 'questionable', controller: 'monsters', action: 'questionable', on: :collection
		get 'autosuggestion', controller: 'monsters', action: 'auto_suggestion'
	end

	devise_for :users
	
	
	match '/static/img/monsters/:size/:id.:basename.png' => "monsters#image_proxy", via: [:get]
	
	root 'news#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
