module Validations
  class ListsValidator < ActiveModel::Validator
    def validate(record)
      if record.lists.blank?
        record.errors[:base] << "At least one list must be selected"
      end
    end
  end
end
