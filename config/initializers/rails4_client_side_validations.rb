# ClientSideValidations Initializer

# Uncomment to disable uniqueness validator, possible security issue
# ClientSideValidations::Config.disabled_validators = [:uniqueness]

# Uncomment to validate number format with current I18n locale
# ClientSideValidations::Config.number_format_with_locale = true

# Uncomment to set a custom application scope
# ClientSideValidations::Config.root_path = '/your/application/scope'

# Uncomment the following block if you want each input field to have the validation messages attached.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  unless html_tag =~ /^<label/
    %{<div class="field_with_errors has-error has-feedback">#{html_tag}</div></div>
    <div class="col-sm-2 bg-danger"><label for="#{instance.send(:tag_id)}" class="message vmiddle">
    #{instance.error_message.first}</label>}.html_safe
  else
    %{<div class="field_with_errors">#{html_tag}</div>}.html_safe
  end
end

