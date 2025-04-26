class User < ApplicationRecord
  has_many :study_tasks, dependent: :destroy
  
  validates :current_score, presence: true, 
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 990 }
  validates :target_score, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 990 }
  validates :study_hours, presence: true,
            numericality: { greater_than: 0 }
  validates :target_date, presence: true
end
