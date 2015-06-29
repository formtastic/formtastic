# encoding: utf-8

# Set the default text field size when input is a string. Default is nil.
# Formtastic::FormBuilder.default_text_field_size = 50

# Set the default text area height when input is a text. Default is 20.
# Formtastic::FormBuilder.default_text_area_height = 5

# Set the default text area width when input is a text. Default is nil.
# Formtastic::FormBuilder.default_text_area_width = 50

# Should all fields be considered "required" by default?
# Defaults to true.
# Formtastic::FormBuilder.all_fields_required_by_default = true

# Should select fields have a blank option/prompt by default?
# Defaults to true.
# Formtastic::FormBuilder.include_blank_for_select_by_default = true

# Set the string that will be appended to the labels/fieldsets which are required.
# It accepts string or procs and the default is a localized version of
# '<abbr title="required">*</abbr>'. In other words, if you configure formtastic.required
# in your locale, it will replace the abbr title properly. But if you don't want to use
# abbr tag, you can simply give a string as below.
# Formtastic::FormBuilder.required_string = "(required)"

# Set the string that will be appended to the labels/fieldsets which are optional.
# Defaults to an empty string ("") and also accepts procs (see required_string above).
# Formtastic::FormBuilder.optional_string = "(optional)"

# Set the way inline errors will be displayed.
# Defaults to :sentence, valid options are :sentence, :list, :first and :none
# Formtastic::FormBuilder.inline_errors = :sentence
# Formtastic uses the following classes as default for hints, inline_errors and error list

# If you override the class here, please ensure to override it in your stylesheets as well.
# Formtastic::FormBuilder.default_hint_class = "inline-hints"
# Formtastic::FormBuilder.default_inline_error_class = "inline-errors"
# Formtastic::FormBuilder.default_error_list_class = "errors"

# Set the method to call on label text to transform or format it for human-friendly
# reading when formtastic is used without object. Defaults to :humanize.
# Formtastic::FormBuilder.label_str_method = :humanize

# Set the array of methods to try calling on parent objects in :select and :radio inputs
# for the text inside each @<option>@ tag or alongside each radio @<input>@. The first method
# that is found on the object will be used.
# Defaults to ["to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]
# Formtastic::FormBuilder.collection_label_methods = [
#   "to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]

# Specifies if labels/hints for input fields automatically be looked up using I18n.
# Default value: true. Overridden for specific fields by setting value to true,
# i.e. :label => true, or :hint => true (or opposite depending on initialized value)
# Formtastic::FormBuilder.i18n_lookups_by_default = false

# Specifies if I18n lookups of the default I18n Localizer should be cached to improve performance.
# Defaults to true.
# Formtastic::FormBuilder.i18n_cache_lookups = false

# Specifies the class to use for localization lookups. You can create your own
# class and use it instead by subclassing Formtastic::Localizer (which is the default).
# Formtastic::FormBuilder.i18n_localizer = MyOwnLocalizer

# You can add custom inputs or override parts of Formtastic by subclassing Formtastic::FormBuilder and
# specifying that class here.  Defaults to Formtastic::FormBuilder.
# Formtastic::Helpers::FormHelper.builder = MyCustomBuilder

# All formtastic forms have a class that indicates that they are just that. You
# can change it to any class you want.
# Formtastic::Helpers::FormHelper.default_form_class = 'formtastic'

# Formtastic will infer a class name from the model, array, string or symbol you pass to the
# form builder. You can customize the way that class is presented by overriding
# this proc.
# Formtastic::Helpers::FormHelper.default_form_model_class_proc = proc { |model_class_name| model_class_name }

# Allows to set a custom field_error_proc wrapper. By default this wrapper
# is disabled since `formtastic` already adds an error class to the LI tag
# containing the input.
# Formtastic::Helpers::FormHelper.formtastic_field_error_proc = proc { |html_tag, instance_tag| html_tag }

# You can opt-in to Formtastic's use of the HTML5 `required` attribute on `<input>`, `<select>`
# and `<textarea>` tags by setting this to true (defaults to false).
# Formtastic::FormBuilder.use_required_attribute = false

# You can opt-in to new HTML5 browser validations (for things like email and url inputs) by setting
# this to true. Doing so will omit the `novalidate` attribute from the `<form>` tag.
# See http://diveintohtml5.org/forms.html#validation for more info.
# Formtastic::FormBuilder.perform_browser_validations = true

# By creating custom input class finder, you can change how input classes  are looked up.
# For example you can make it to search for TextInputFilter instead of TextInput.
# See # TODO: add link # for more information
# NOTE: this behavior will be default from Formtastic 4.0
Formtastic::FormBuilder.input_class_finder = Formtastic::InputClassFinder

# Define custom namespaces in which to look up your Input classes. Default is
# to look up in the global scope and in Formtastic::Inputs.
# Formtastic::FormBuilder.input_namespaces = [ ::Object, ::MyInputsModule, ::Formtastic::Inputs ]

# By creating custom action class finder, you can change how action classes are looked up.
# For example you can make it to search for MyButtonAction instead of ButtonAction.
# See # TODO: add link # for more information
# NOTE: this behavior will be default from Formtastic 4.0
Formtastic::FormBuilder.action_class_finder = Formtastic::ActionClassFinder

# Define custom namespaces in which to look up your Action classes. Default is
# to look up in the global scope and in Formtastic::Actions.
# Formtastic::FormBuilder.action_namespaces = [ ::Object, ::MyActionsModule, ::Formtastic::Actions ]

# Which columns to skip when automatically rendering a form without any fields specified.
# Formtastic::FormBuilder.skipped_columns = [:created_at, :updated_at, :created_on, :updated_on, :lock_version, :version]
