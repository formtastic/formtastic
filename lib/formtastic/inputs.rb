module Formtastic
  module Inputs
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Basic
    autoload :Timeish

    eager_autoload do
      autoload :BooleanInput
      autoload :CheckBoxesInput
      autoload :ColorInput
      autoload :CountryInput
      autoload :DatalistInput
      autoload :DateInput
      autoload :DatePickerInput
      autoload :DatetimePickerInput
      autoload :DateSelectInput
      autoload :DatetimeInput
      autoload :DatetimeSelectInput
      autoload :EmailInput
      autoload :FileInput
      autoload :HiddenInput
      autoload :NumberInput
      autoload :NumericInput
      autoload :PasswordInput
      autoload :PhoneInput
      autoload :RadioInput
      autoload :RangeInput
      autoload :SearchInput
      autoload :SelectInput
      autoload :StringInput
      autoload :TextInput
      autoload :TimeInput
      autoload :TimePickerInput
      autoload :TimeSelectInput
      autoload :TimeZoneInput
      autoload :UrlInput
    end
  end
end

