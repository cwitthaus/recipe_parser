class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.integer :number
      t.text :description
      t.integer :recipe_id
      t.timestamps
    end
  end
end
