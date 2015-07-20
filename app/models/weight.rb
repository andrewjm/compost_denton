class Weight < ActiveRecord::Base
  belongs_to :user
  belongs_to :member
  validates :user_id, presence: true
  validates :member_id, presence: true
end
