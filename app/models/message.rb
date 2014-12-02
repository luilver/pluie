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

  def deliver
    publisher =  PluieWisper::MessagePublisher.new
    publisher.notify_msg_to_observers(self)
  end

  private
    def message_cost_is_on_budget
      if route
        cost = message_cost
        dl = -user.max_debt
        if (user.balance - cost) < dl
          errors[:base] << I18n.translate('errors.messages.debit_limit_violation', cost: cost, limit: -dl).html_safe
        end
      end
    end
end
