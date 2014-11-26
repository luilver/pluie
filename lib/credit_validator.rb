require 'action_smser_utils'

module Validations
  class CreditValidator < ActiveModel::Validator
    def validate(record)
      unless record.route
        record.errors[:base] << I18n.t(:not_route_error)
      else
        cost = record.message_cost
        dl = -record.user.max_debt
        if (record.user.balance - cost) < dl
          record.errors[:base] << I18n.translate('errors.messages.debit_limit_violation', cost: cost, limit: -dl).html_safe
        end
      end
    end
  end
end
