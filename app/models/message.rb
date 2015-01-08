class Message < ActiveRecord::Base
  self.abstract_class = true
  include Gsmeable
  include Chargeable
  include PluieMessageId

  belongs_to :route
  belongs_to :user
  validates :message, presence: true
  validates :route, presence: true
  validate :message_cost_is_on_budget

  private
    def message_cost_is_on_budget
      if route
        cost = message_cost
        if user.balance < cost
          errors[:base] << I18n.translate('errors.messages.insufficient_funds', cost: cost).html_safe
        end
      end
    end
end
