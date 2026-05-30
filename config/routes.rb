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

  # =========================================================================
  # Standard CRUD Routes for :pets Cheat Sheet
  # =========================================================================
  #
  # INDEX / CREATE
  #   GET    /pets                       => pets#index                 (pets_path)
  #   POST   /pets                       => pets#create                (pets_path)
  #
  # NEW / EDIT
  #   GET    /pets/new                   => pets#new                   (new_pet_path)
  #   GET    /pets/:id/edit              => pets#edit                  (edit_pet_path)
  #
  # SHOW / UPDATE / DELETE
  #   GET    /pets/:id                   => pets#show                  (pet_path)
  #   PATCH  /pets/:id                   => pets#update                (pet_path)
  #   PUT    /pets/:id                   => pets#update                (pet_path)
  #   DELETE /pets/:id                   => pets#destroy               (pet_path)
  #
  # =========================================================================
  resources :pets do
    # Styled delete confirmation, shown in the shared modal (drawer frame)
    # instead of the browser's native confirm() dialog.
    #   GET /pets/:id/confirm_delete => pets#confirm_delete (confirm_delete_pet_path)
    get :confirm_delete, on: :member

    # =====================================================================
    # Care Team Routes (nested under :pets) Cheat Sheet
    # =====================================================================
    #
    # A pet's care team (vets, groomers, sitters, etc.). Nested because a
    # member only exists in the context of one pet. There is no index/show:
    # the team is rendered on the pet profile and all CRUD runs through the
    # shared modal.
    #
    # NEW / CREATE
    #   GET    /pets/:pet_id/care_team_members/new      => care_team_members#new    (new_pet_care_team_member_path)
    #   POST   /pets/:pet_id/care_team_members          => care_team_members#create (pet_care_team_members_path)
    #
    # EDIT / UPDATE / DELETE
    #   GET    /pets/:pet_id/care_team_members/:id/edit => care_team_members#edit    (edit_pet_care_team_member_path)
    #   PATCH  /pets/:pet_id/care_team_members/:id      => care_team_members#update  (pet_care_team_member_path)
    #   PUT    /pets/:pet_id/care_team_members/:id      => care_team_members#update  (pet_care_team_member_path)
    #   DELETE /pets/:pet_id/care_team_members/:id      => care_team_members#destroy (pet_care_team_member_path)
    #
    # =====================================================================
    resources :care_team_members, only: %i[new create edit update destroy] do
      # Styled delete confirmation, shown in the shared modal (drawer frame)
      # instead of the browser's native confirm() dialog.
      #   GET /pets/:pet_id/care_team_members/:id/confirm_delete => care_team_members#confirm_delete (confirm_delete_pet_care_team_member_path)
      get :confirm_delete, on: :member
    end
  end

  root "pets#index"
end
