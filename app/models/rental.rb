class Rental < ApplicationRecord
  STATUSES = ["checked out", "returned"]

  belongs_to :customer
  belongs_to :movie

  validates :check_out_date, presence: true
  validates :due_date, presence: true
  validates :status,  presence: true, inclusion: { in: STATUSES }

end
