module Validations
  class CreditValidator < ActiveModel::Validator
    def validate(record)
      unless record.route
        record.errors[:base] << "#{I18n.t(:not_route_error)}"
      else
        cost = record.receivers.size * record.route.price
        cl = record.user.credit_limit
        if (record.user.balance - cost) < cl
          record.errors[:base] << "Message cost(#{cost}) violates your credit limit (#{cl})"
        end
      end
    end
  end
end
