class Topup < ActiveRecord::Base
  belongs_to :user

  RECHARGE_TYPES = [
    "10",
    "15",
    "20",
    "25",
    "30",
    "35",
    "40",
    "45",
    "50",
  ]
end
