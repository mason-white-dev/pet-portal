class RenameContactNameToOrganizationOnCareTeamMembers < ActiveRecord::Migration[8.1]
  def change
    rename_column :care_team_members, :contact_name, :organization
  end
end
