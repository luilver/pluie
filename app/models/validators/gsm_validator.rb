class GsmValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    v = value || "" #to avoid nil values in shoulda tests
    numbers = v.split(/[[:blank:]]/)
    numbers.each do |num|
      unless num =~ /535[0-9]{7}/
        record.errors[attribute] << (options[:message] || I18n.t('errors.messages.invalid_cubacel_number', num: num))
      end
    end
  end
end
