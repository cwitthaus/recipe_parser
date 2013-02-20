class Ingredient < ActiveRecord::Base
  attr_accessible :amount, :modifiers, :name, :original_text
  belongs_to :recipe, dependent: :destroy
  validates_presence_of :name
  validates_presence_of :original_text
end
