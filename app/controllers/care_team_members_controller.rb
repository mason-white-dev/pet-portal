class CareTeamMembersController < ApplicationController
  before_action :set_pet
  before_action :set_care_team_member, only: %i[ edit update destroy confirm_delete ]

  # GET /pets/1/care_team_members/new
  def new
    @care_team_member = @pet.care_team_members.build
    # Members are only added through the modal (drawer frame) on the pet profile.
    # A direct visit gets bounced to the profile. On a frame request we send back
    # just the frame (no layout), same as edit.
    if turbo_frame_request?
      render layout: false
    else
      redirect_to pet_path(@pet)
    end
  end

  # GET /pets/1/care_team_members/1/edit
  def edit
    # Same modal-only pattern as new: only render the drawer frame on a frame
    # request, bounce a direct visit back to the profile.
    if turbo_frame_request?
      render layout: false
    else
      redirect_to pet_path(@pet)
    end
  end

  # POST /pets/1/care_team_members
  def create
    @care_team_member = @pet.care_team_members.build(care_team_member_params)

    if @care_team_member.save
      respond_to do |format|
        # The form lives inside the drawer frame, so a plain redirect would stay
        # trapped in the frame. The custom "redirect" stream action (see
        # application.js) does a full-page Turbo.visit back to the pet profile.
        format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, pet_path(@pet)) }
        format.html { redirect_to pet_path(@pet), notice: "Care team member was successfully added." }
      end
    else
      # Re-render the form (422) into the drawer frame so errors show in the
      # still-open modal. layout: false keeps the response to just the frame.
      render :new, status: :unprocessable_entity, layout: false
    end
  end

  # PATCH/PUT /pets/1/care_team_members/1
  def update
    if @care_team_member.update(care_team_member_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, pet_path(@pet)) }
        format.html { redirect_to pet_path(@pet), notice: "Care team member was successfully updated." }
      end
    else
      # Re-render into the drawer frame (errors in the open modal). layout: false
      # keeps it frame-only.
      render :edit, status: :unprocessable_entity, layout: false
    end
  end

  # GET /pets/1/care_team_members/1/confirm_delete
  def confirm_delete
    # Same modal-only pattern as new/edit: render just the drawer frame on a
    # frame request, bounce a direct visit back to the profile.
    if turbo_frame_request?
      render layout: false
    else
      redirect_to pet_path(@pet)
    end
  end

  # DELETE /pets/1/care_team_members/1
  def destroy
    @care_team_member.destroy!

    respond_to do |format|
      format.html { redirect_to pet_path(@pet), notice: "Care team member was successfully removed.", status: :see_other }
    end
  end

  private
    # Load the parent pet, scoped to the signed-in user's pets. A pet that isn't
    # theirs simply isn't found (404) — this is the root of the authorization story.
    def set_pet
      @pet = current_user.pets.find(params[:pet_id])
    end

    # Load the member *through* @pet, so it can only ever be one hanging off a pet
    # the user owns. No cross-account access is possible.
    def set_care_team_member
      @care_team_member = @pet.care_team_members.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def care_team_member_params
      params.expect(care_team_member: [ :role, :name, :contact_name, :phone, :email, :notes ])
    end
end
