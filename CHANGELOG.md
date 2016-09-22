## master

  * Fixed missing constants in production (#911)
  * Removed support for Rails 3 and 4.0 (#1108)
  * Removed deprecated input/action finder methods (#1139)
  * Changed boolean label padding to margin (#1202)
  * Added mapping hstore column to text input (#1203)
  * Added support for Rails 5 Attributes API (#1188)
  * Changed required Ruby version to >= 2.0 (#1210)

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
https://github.com/justinfrench/formtastic/blob/3.0-stable/CHANGELOG

See 2.3-stable branch for 2.3.x and earlier releases
https://github.com/justinfrench/formtastic/blob/2.3-stable/CHANGELOG
