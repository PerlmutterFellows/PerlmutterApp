class UserScore < ApplicationRecord
  has_many :subscores
  belongs_to :user
end
