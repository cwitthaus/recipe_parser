class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :original_text
      t.string :amount
      t.string :name
      t.string :modifiers
      t.integer :recipe_id
      t.timestamps
    end
  end
end
