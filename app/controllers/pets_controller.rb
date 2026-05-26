class PetsController < ApplicationController
  before_action :set_pet, only: %i[ show edit update destroy ]

  # GET /pets 
  def index
    # with_attached_avatar_image eager-loads the attachment + blob so the roster
    # doesn't fire a query per pet when rendering avatars (avoids N+1).
    @pets = current_user.pets.with_attached_avatar_image
  end

  # GET /pets/1
  def show
  end

  # GET /pets/new
  def new
    @pet = current_user.pets.build
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

    respond_to do |format|
      if @pet.save
        format.html { redirect_to @pet, notice: "Pet was successfully created." }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /pets/1
  def update
    if @pet.update(pet_params)
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
end
