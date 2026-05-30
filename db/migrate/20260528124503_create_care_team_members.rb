class CreateCareTeamMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :care_team_members do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :role
      t.string :name
      t.string :contact_name
      t.string :phone
      t.string :email
      t.text :notes

      t.timestamps
    end
  end
end
