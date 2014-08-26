module Validations
  class CreditValidator < ActiveModel::Validator
    def validate(record)
      cost = record.receivers.size * record.route.price
      cl = record.user.credit_limit
      if (record.user.balance - cost) < cl
        record.errors[:base] << "Message cost(#{cost}) is greater than your credit limit (#{cl})"
      end
    end
  end
end
