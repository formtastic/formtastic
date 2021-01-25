## master

##  4.0.0

  * Support Rails 6.1 (#1324)

##  4.0.0.rc1

  * Fixed default_columns_for_object when object has non-standard foreign keys (#1241)
  * Fixed missing constants in production (#911)
  * Removed support for Rails 3 and 4.0 (#1108)
  * Removed deprecated input/action finder methods (#1139)
  * Changed boolean label padding to margin (#1202)
  * Added mapping hstore column to text input (#1203)
  * Added support for Rails 5 Attributes API (#1188)
  * Changed required Ruby version to >= 2.0 (#1210)
  * Default to input types text for json & jsonb, string for citext columns (#1229)
  * Allow symbols for numericality options (#1258)
  * Support for rubies under 2.4.0 has been dropped (#1292)
  * Support for Rails under 5.2.0 has been dropped (#1293)

## 3.1.2

  * Fixed that we specified 4.0.4 instead of 4.1 in the Rails version deprecation message

## 3.1.1

  * Fixed class custom input & action class loading in test environments
  * Added documentation of custom input & action class finders
  * Added a link to documentation & wiki from custom class deprecation warnings

## 3.1.0

  * Performance and documentation improvements

## 3.1.0.rc2

  * Deprecated :member_value and :member_label options

## 3.1.0.rc1

  * Deprecated support for Rails version < 4.1.0
  * Fixed synchronization issues with custom_namespace configuration
  * Fixed bug where boolean (checkbox) inputs were not being correctly checked (also in 2.3.1)
  * Fixed (silenced) Rails 5 deprecation on column_for_attribute that we're handling fine
  * Added new DatalistInput (:as => :datalist) for HTML5 datalists
  * Added configurable namespaces for custom inputs
  * Various performance and documentation improvements

---

See 3.0-stable branch for 3.0.x changes
https://github.com/formtastic/formtastic/blob/3.0-stable/CHANGELOG

See 2.3-stable branch for 2.3.x and earlier releases
https://github.com/formtastic/formtastic/blob/2.3-stable/CHANGELOG
