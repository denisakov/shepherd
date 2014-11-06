class ImoFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^[0-9]{7}*$/
      record.errors[attribute] << (options[:message] || "there must 7 digits only")
    end
  end
end