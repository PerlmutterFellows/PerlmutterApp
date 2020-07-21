class UserScore < ApplicationRecord
  has_many :subscores
  belongs_to :user

  def get_total_score
    score = 0
    max_score = 0
    self.subscores.each do |subscore|
      score += subscore.score
      max_score += subscore.max_score
    end
    {
        score: score,
        max_score: max_score
    }
  end
end
