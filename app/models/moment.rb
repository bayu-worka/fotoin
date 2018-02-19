class Moment < ApplicationRecord
  has_many :photos, inverse_of: :moment, dependent: :destroy
  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true
  belongs_to :user

  validates_presence_of :title, :photos

end
