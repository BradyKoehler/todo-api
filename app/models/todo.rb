class Todo < ApplicationRecord
  validates :title, presence: true
  validates :status, presence: true
  validates :list_id, presence: true

  enum status: { incomplete: 0, complete: 1 }

  belongs_to :list
end
