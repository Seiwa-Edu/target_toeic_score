class CreateStudyTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :study_tasks do |t|
      t.string :title
      t.text :description
      t.boolean :completed
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
