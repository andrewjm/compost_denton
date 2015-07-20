class Member < ActiveRecord::Base
  belongs_to :user
  has_many :weights
  validates :user_id, presence: true
  geocoded_by :address_line_one
  after_validation :geocode
end
