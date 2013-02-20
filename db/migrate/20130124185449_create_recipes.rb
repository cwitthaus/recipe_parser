class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.text :original_text_info
      t.text :original_text_ingredients
      t.text :original_text_steps
      t.string :title
      t.string :source
      t.string :prep_time
      t.string :cook_time

      t.timestamps
    end
  end
end
