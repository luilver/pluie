module Validations
  class CreditValidator < ActiveModel::Validator
    def validate(record)
      unless record.route
        record.errors[:base] << I18n.t(:not_route_error)
      else
        cost = record.gsm_numbers_count * record.route.price
        cl = record.user.credit_limit
        if (record.user.balance - cost) < cl
          record.errors[:base] << I18n.translate('errors.messages.debit_limit_violation', cost: cost, limit: cl).html_safe
        end
      end
    end
  end
end
