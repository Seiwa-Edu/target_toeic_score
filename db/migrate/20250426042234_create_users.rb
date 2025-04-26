class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.integer :current_score
      t.integer :target_score
      t.float :study_hours
      t.date :target_date

      t.timestamps
    end
  end
end
