class Credit < ActiveRecord::Base
  belongs_to :user
  before_save :save_owner if :new_record?
  validates :balance, presence: true
  validates :balance,  numericality: { greater_than: 0}
  validates :user, presence: true
  after_save :update_credit_on_user

  def save_owner
    self.user.save
  end

  def to_s
    self.balance.to_s
  end

  private
    def update_credit_on_user
      if balance_changed?
        user.credit += (balance - (balance_was || 0))
        user.save
      end
    end
end
