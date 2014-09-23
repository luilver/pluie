class Credit < ActiveRecord::Base
  belongs_to :user
  before_save :save_owner
  validates :balance, presence: true
  validates :balance,  numericality: {only_integer: true, greater_than: 0}
  validates :user, presence: true
  around_update :update_user_credit

  def save_owner
    self.user.save
  end

  def self.random
    Credit.all[rand Credit.count]
  end

  private
    def update_user_credit
      old_c = self.balance
      yield
      if self.valid?
        new_c = self.user.credit - old_c + self.balance
        self.user.update(credit: new_c)
      end
    end
end
