# encoding: utf-8

# --------------------------------------------------------------------------------------------------
# Please note: If you're subclassing Formtastic::SemanticFormBuilder in a Rails 3 project, 
# Formtastic uses class_attribute for these configuration attributes instead of the deprecated 
# class_inheritable_attribute. The behaviour is slightly different with subclasses (especially 
# around attributes with Hash or Array) values, so make sure you understand what's happening. 
# See the documentation for class_attribute in ActiveSupport for more information.
# --------------------------------------------------------------------------------------------------

# Set the default text field size when input is a string. Default is nil.
# Formtastic::SemanticFormBuilder.default_text_field_size = 50

# Set the default text area height when input is a text. Default is 20.
# Formtastic::SemanticFormBuilder.default_text_area_height = 5

# Set the default text area width when input is a text. Default is nil.
# Formtastic::SemanticFormBuilder.default_text_area_width = 50

# Should all fields be considered "required" by default?
# Rails 2 only, ignored by Rails 3 because it will never fall back to this default.
# Defaults to true.
# Formtastic::SemanticFormBuilder.all_fields_required_by_default = true

# Should select fields have a blank option/prompt by default?
# Defaults to true.
# Formtastic::SemanticFormBuilder.include_blank_for_select_by_default = true

# Set the string that will be appended to the labels/fieldsets which are required
# It accepts string or procs and the default is a localized version of
# '<abbr title="required">*</abbr>'. In other words, if you configure formtastic.required
# in your locale, it will replace the abbr title properly. But if you don't want to use
# abbr tag, you can simply give a string as below
# Formtastic::SemanticFormBuilder.required_string = "(required)"

# Set the string that will be appended to the labels/fieldsets which are optional
# Defaults to an empty string ("") and also accepts procs (see required_string above)
# Formtastic::SemanticFormBuilder.optional_string = "(optional)"

# Set the way inline errors will be displayed.
# Defaults to :sentence, valid options are :sentence, :list, :first and :none
# Formtastic::SemanticFormBuilder.inline_errors = :sentence
# Formtastic uses the following classes as default for hints, inline_errors and error list

# If you override the class here, please ensure to override it in your formtastic_changes.css stylesheet as well
# Formtastic::SemanticFormBuilder.default_hint_class = "inline-hints"
# Formtastic::SemanticFormBuilder.default_inline_error_class = "inline-errors"
# Formtastic::SemanticFormBuilder.default_error_list_class = "errors"

# Set the method to call on label text to transform or format it for human-friendly
# reading when formtastic is used without object. Defaults to :humanize.
# Formtastic::SemanticFormBuilder.label_str_method = :humanize

# Set the array of methods to try calling on parent objects in :select and :radio inputs
# for the text inside each @<option>@ tag or alongside each radio @<input>@. The first method
# that is found on the object will be used.
# Defaults to ["to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]
# Formtastic::SemanticFormBuilder.collection_label_methods = [
#   "to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]

# Formtastic by default renders inside li tags the input, hints and then
# errors messages. Sometimes you want the hints to be rendered first than
# the input, in the following order: hints, input and errors. You can
# customize it doing just as below:
# Formtastic::SemanticFormBuilder.inline_order = [:input, :hints, :errors]

# Additionally, you can customize the order for specific types of inputs.
# This is configured on a type basis and if a type is not found it will
# fall back to the default order as defined by #inline_order
# Formtastic::SemanticFormBuilder.custom_inline_order[:checkbox] = [:errors, :hints, :input]
# Formtastic::SemanticFormBuilder.custom_inline_order[:select] = [:hints, :input, :errors]

# Specifies if labels/hints for input fields automatically be looked up using I18n.
# Default value: false. Overridden for specific fields by setting value to true,
# i.e. :label => true, or :hint => true (or opposite depending on initialized value)
# Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false

# You can add custom inputs or override parts of Formtastic by subclassing SemanticFormBuilder and
# specifying that class here.  Defaults to SemanticFormBuilder.
# Formtastic::SemanticFormHelper.builder = MyCustomBuilder
