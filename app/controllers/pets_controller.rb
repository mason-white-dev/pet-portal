class PetsController < ApplicationController
  before_action :set_pet, only: %i[ show edit update destroy confirm_delete ]

  # GET /pets
  def index
    # with_attached_avatar_image eager-loads the attachment + blob so the roster
    # doesn't fire a query per pet when rendering avatars (avoids N+1).
    # Newest first, so the most recently added pet leads the roster.
    @pets = current_user.pets.with_attached_avatar_image.order(created_at: :desc)
  end

  # GET /pets/1
  def show
  end

  # GET /pets/new
  def new
    @pet = current_user.pets.build
    # New pets are only added through the modal (drawer frame) on the index — a
    # direct visit to /pets/new gets bounced to the roster. On a frame request we
    # send back just the frame (no layout), same as edit.
    if turbo_frame_request?
      render layout: false
    else
      redirect_to pets_path
    end
  end

  # GET /pets/1/edit
  def edit
    # We only want users to edit their pet through the context of the modal on the show page.
    # We don't want them to go to a full, stand alone 'edit' page. Also, becuase we only edit
    # through the modal, only send back the turbo frame (don't render and send the whole layout).
    if turbo_frame_request?
      render layout: false
    else
      redirect_to pet_path(@pet)
    end
  end

  # POST /pets
  def create
    @pet = current_user.pets.build(pet_params)

    if @pet.save
      respond_to do |format|
        # The form lives inside the drawer frame, so a plain redirect would stay
        # trapped in the frame. The custom "redirect" stream action (see
        # application.js) does a full-page Turbo.visit to the new pet's profile.
        format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, pet_path(@pet)) }
        format.html { redirect_to @pet, notice: "Pet was successfully created." }
      end
    else
      # Mirrors edit's failure path: re-render the form (422) into the drawer
      # frame so errors show in the still-open modal.
      render :new, status: :unprocessable_entity
    end
  end

  # GET /pets/1/confirm_delete
  def confirm_delete
    # Same modal-only pattern as new/edit: render just the drawer frame on a
    # frame request, bounce a direct visit back to the profile.
    if turbo_frame_request?
      render layout: false
    else
      redirect_to pet_path(@pet)
    end
  end

  # PATCH/PUT /pets/1
  def update
    if @pet.update(pet_params)
      # The modal's "Remove photo" button sets pet[remove_avatar_image] = "1".
      # It's not a real attribute (so not in pet_params) — read it directly and
      # purge after a successful save. Synchronous `purge` (not `purge_later`) so
      # the turbo_stream below re-renders the card with the photo already gone.
      @pet.avatar_image.purge if remove_avatar_image?

      respond_to do |format|
        format.turbo_stream                          # → update.turbo_stream.erb
        format.html { redirect_to pet_path(@pet) }   # fallback
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pets/1
  def destroy
    @pet.destroy!

    respond_to do |format|
      format.html { redirect_to pets_path, notice: "Pet was successfully destroyed.", status: :see_other }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pet
      @pet = current_user.pets.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def pet_params
      params.expect(pet: [ :name, :species, :sex, :breed, :date_of_birth, :microchip, :neutered, :notes, :avatar_image ])
    end

    # True when the user asked to remove the photo AND didn't also pick a new one
    # (the new-file check is belt-and-suspenders — the JS clears the flag on pick).
    def remove_avatar_image?
      ActiveModel::Type::Boolean.new.cast(params.dig(:pet, :remove_avatar_image)) &&
        params.dig(:pet, :avatar_image).blank? &&
        @pet.avatar_image.attached?
    end
end
