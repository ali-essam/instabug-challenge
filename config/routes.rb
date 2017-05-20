Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :bugs, param: :number do
    resource :state, only: :show
  end
end
