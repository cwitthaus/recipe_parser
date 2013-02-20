class Recipe < ActiveRecord::Base
  attr_accessible :cook_time, :original_text_info, :original_text_ingredients, :original_text_steps, :prep_time, :source, :title
  attr_accessible :steps_attributes, :ingredients_attributes
  has_many :steps
  has_many :ingredients

  validates_presence_of :title
  validates_presence_of :original_text_info
  validates_presence_of :original_text_ingredients
  validates_presence_of :original_text_steps

  accepts_nested_attributes_for :steps, :allow_destroy => true
  accepts_nested_attributes_for :ingredients, :allow_destroy => true
end
