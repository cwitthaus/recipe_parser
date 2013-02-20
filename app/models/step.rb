class Step < ActiveRecord::Base
  attr_accessible :description, :number
  belongs_to :recipes, dependent: :destroy

  validates_presence_of :description
  validates_presence_of :number
end
