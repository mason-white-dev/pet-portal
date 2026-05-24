Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check



  # =========================================================================
  # Devise Routes for :users Cheat Sheet
  # =========================================================================
  #
  # SESSIONS (Log In / Log Out)
  #   GET    /users/sign_in              => devise/sessions#new        (new_user_session_path)
  #   POST   /users/sign_in              => devise/sessions#create     (user_session_path)
  #   DELETE /users/sign_out             => devise/sessions#destroy    (destroy_user_session_path)
  #
  # PASSWORDS (Reset Passwords)
  #   GET    /users/password/new         => devise/passwords#new       (new_user_password_path)
  #   POST   /users/password             => devise/passwords#create    (user_password_path)
  #   GET    /users/password/edit        => devise/passwords#edit      (edit_user_password_path)
  #   PATCH  /users/password             => devise/passwords#update    (user_password_path)
  #   PUT    /users/password             => devise/passwords#update
  #
  # REGISTRATIONS (Sign Up / Edit Account / Delete Account)
  #   GET    /users/sign_up              => devise/registrations#new   (new_user_registration_path)
  #   POST   /users/sign_up              => devise/registrations#create(user_registration_path)
  #   GET    /users/edit                 => devise/registrations#edit  (edit_user_registration_path)
  #   PATCH  /users                      => devise/registrations#update(user_registration_path)
  #   PUT    /users                      => devise/registrations#update
  #   DELETE /users                      => devise/registrations#destroy(user_registration_path)
  #   GET    /users/cancel               => devise/registrations#cancel(cancel_user_registration_path)
  #
  # =========================================================================
  devise_for :users

  root "dashboard#index"
end
