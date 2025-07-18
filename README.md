# Formtastic

[![Build Status](https://github.com/formtastic/formtastic/workflows/test/badge.svg)](https://github.com/formtastic/formtastic/actions)
[![Inline docs](https://inch-ci.org/github/justinfrench/formtastic.svg?branch=master)](https://inch-ci.org/github/justinfrench/formtastic)
[![Code Climate](https://codeclimate.com/github/formtastic/formtastic/badges/gpa.svg)](https://codeclimate.com/github/formtastic/formtastic)
[![Gem Version](https://badge.fury.io/rb/formtastic.svg)](https://badge.fury.io/rb/formtastic)

Formtastic is a Rails FormBuilder DSL (with some other goodies) to make it far easier to create beautiful, semantically rich, syntactically awesome, readily stylable and wonderfully accessible HTML forms in your Rails applications.

## Documentation & Support

* [Documentation is available on rubydoc.info](https://rubydoc.info/github/formtastic/formtastic)
* [We track issues & bugs on GitHub](https://github.com/formtastic/formtastic/issues)
* [We have a wiki on GitHub](https://github.com/formtastic/formtastic/wiki)
* [StackOverflow can help](https://stackoverflow.com/questions/tagged/formtastic)

## Compatibility

* Formtastic edge requires Rails 7.2 and Ruby 3.1 minimum, inline with Rails minimum supported versions
* Formtastic 5.0 requires Rails 6.0 and Ruby 2.6 minimum
* Formtastic, much like Rails, is very ActiveRecord-centric. Many are successfully using other ActiveModel-like ORMs and objects (DataMapper, MongoMapper, Mongoid, Authlogic, Devise...) but we're not guaranteeing full compatibility at this stage. Patches are welcome!

## The Story

One day, I finally had enough, so I opened up my text editor, and wrote a DSL for how I'd like to author forms:

```erb
  <%= semantic_form_for @article do |f| %>

    <%= f.inputs :name => "Basic" do %>
      <%= f.input :title %>
      <%= f.input :body %>
      <%= f.input :section %>
      <%= f.input :publication_state, :as => :radio %>
      <%= f.input :category %>
      <%= f.input :allow_comments, :label => "Allow commenting on this article" %>
    <% end %>

    <%= f.inputs :name => "Advanced" do %>
      <%= f.input :keywords, :required => false, :hint => "Example: ruby, rails, forms" %>
      <%= f.input :extract, :required => false %>
      <%= f.input :description, :required => false %>
      <%= f.input :url_title, :required => false %>
    <% end %>

    <%= f.inputs :name => "Author", :for => :author do |author_form| %>
      <%= author_form.input :first_name %>
      <%= author_form.input :last_name %>
    <% end %>

    <%= f.actions do %>
      <%= f.action :submit, :as => :button %>
      <%= f.action :cancel, :as => :link %>
    <% end %>

  <% end %>
```

I also wrote the accompanying HTML output I expected, favoring something very similar to the fieldsets, lists and other semantic elements Aaron Gustafson presented in [Learning to Love Forms](https://www.slideshare.net/AaronGustafson/learning-to-love-forms-webvisions-07), hacking together enough Ruby to prove it could be done.


## It's awesome because...

* It can handle `belongs_to` associations (like Post belongs_to :author), rendering a select or set of radio inputs with choices from the parent model.
* It can handle `has_many` and `has_and_belongs_to_many` associations (like: Post has_many :tags), rendering a multi-select with choices from the child models.
* It's Rails 3/4 compatible (including nested forms).
* It has internationalization (I18n)!
* It's _really_ quick to get started with a basic form in place (4 lines), then go back to add in more detail if you need it.
* There's heaps of elements, id and class attributes for you to hook in your CSS and JS.
* It handles real world stuff like inline hints, inline error messages & help text.
* It doesn't hijack or change any of the standard Rails form inputs, so you can still use them as expected (even mix and match).
* It's got absolutely awesome spec coverage.
* There's a bunch of people using and working on it (it's not just one developer building half a solution).
* It has growing HTML5 support (new inputs like email/phone/search, new attributes like required/min/max/step/placeholder)


## Opinions

* It should be easier to do things the right way than the wrong way.
* Sometimes _more mark-up_ is better.
* Elements and attribute hooks are _gold_ for stylesheet authors.
* Make the common things we do easy, yet ensure uncommon things are still possible.


## Installation

Simply add Formtastic to your Gemfile and bundle it up:

```ruby
  gem 'formtastic', '~> 5.0'
```

Run the installation generator:

```shell
$ rails generate formtastic:install
```


## Stylesheets

An optional proof-of-concept stylesheet can be generated and installed into your app:

```shell
$ rails generate formtastic:stylesheet
```


## Usage

Forms are really boring to code... you want to get onto the good stuff as fast as possible.

This renders a set of inputs (one for _most_ columns in the database table, and one for each ActiveRecord `belongs_to`-association), followed by default action buttons (an input submit button):

```erb
  <%= semantic_form_for @user do |f| %>
    <%= f.inputs %>
    <%= f.actions %>
  <% end %>
```

This is a great way to get something up fast, but like scaffolding, it's *not recommended for production*. Don't be so lazy!

To specify the order of the fields, skip some of the fields or even add in fields that Formtastic couldn't infer. You can pass in a list of field names to `inputs` and list of action names to `actions`:

```erb
  <%= semantic_form_for @user do |f| %>
    <%= f.inputs :title, :body, :section, :categories, :created_at %>
    <%= f.actions :submit, :cancel %>
  <% end %>
```

You probably want control over the input type Formtastic uses for each field. You can expand the `inputs` and `actions` to block helper format and use the `:as` option to specify an exact input type:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs do %>
      <%= f.input :title %>
      <%= f.input :body %>
      <%= f.input :section, :as => :radio %>
      <%= f.input :categories %>
      <%= f.input :created_at, :as => :string %>
    <% end %>
    <%= f.actions do %>
      <%= f.action :submit, :as => :button %>
      <%= f.action :cancel, :as => :link %>
    <% end %>
  <% end %>
```

If you want to customize the label text, or render some hint text below the field, specify which fields are required/optional, or break the form into two fieldsets, the DSL is pretty comprehensive:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs "Basic", :id => "basic" do %>
      <%= f.input :title %>
      <%= f.input :body %>
    <% end %>
    <%= f.inputs :name => "Advanced Options", :id => "advanced" do %>
      <%= f.input :slug, :label => "URL Title", :hint => "Created automatically if left blank", :required => false %>
      <%= f.input :section, :as => :radio %>
      <%= f.input :user, :label => "Author" %>
      <%= f.input :categories, :required => false %>
      <%= f.input :created_at, :as => :string, :label => "Publication Date", :required => false %>
    <% end %>
    <%= f.actions do %>
      <%= f.action :submit %>
    <% end %>
  <% end %>
```

You can create forms for nested resources:

```erb
	<%= semantic_form_for [@author, @post] do |f| %>
```

Nested forms are also supported (don't forget your models need to be setup correctly with `accepts_nested_attributes_for`). You can do it in the Rails way:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs :title, :body, :created_at %>
    <%= f.semantic_fields_for :author do |author| %>
      <%= author.inputs :first_name, :last_name, :name => "Author" %>
    <% end %>
    <%= f.actions %>
  <% end %>
```

Or the Formtastic way with the `:for` option:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs :title, :body, :created_at %>
    <%= f.inputs :first_name, :last_name, :for => :author, :name => "Author" %>
    <%= f.actions %>
  <% end %>
```

When working in has many association, you can even supply `"%i"` in your fieldset name; they will be properly interpolated with the child index. For example:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs %>
    <%= f.inputs :name => 'Category #%i', :for => :categories %>
    <%= f.actions %>
  <% end %>
```

Alternatively, the current index can be accessed via the `inputs` block's arguments for use anywhere:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs :for => :categories do |category, i| %>
      ...
    <%= f.actions %>
  <% end %>
```

If you have more than one form on the same page, it may lead to HTML invalidation because of the way HTML element id attributes are assigned. You can provide a namespace for your form to ensure uniqueness of id attributes on form elements. The namespace attribute will be prefixed with underscore on the generate HTML id. For example:

```erb
  <%= semantic_form_for(@post, :namespace => 'cat_form') do |f| %>
    <%= f.inputs do %>
      <%= f.input :title %>        # id="cat_form_post_title"
      <%= f.input :body %>         # id="cat_form_post_body"
      <%= f.input :created_at %>   # id="cat_form_post_created_at"
    <% end %>
    <%= f.actions %>
  <% end %>
```

Customize HTML attributes for any input using the `:input_html` option. Typically this is used to disable the input, change the size of a text field, change the rows in a textarea, or even to add a special class to an input to attach special behavior like [autogrow](https://plugins.jquery.com/project/autogrowtextarea) textareas:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs do %>
      <%= f.input :title,      :input_html => { :size => 10 } %>
      <%= f.input :body,       :input_html => { :class => 'autogrow', :rows => 10, :cols => 20, :maxlength => 10  } %>
      <%= f.input :created_at, :input_html => { :disabled => true } %>
      <%= f.input :updated_at, :input_html => { :readonly => true } %>
    <% end %>
    <%= f.actions %>
  <% end %>
```

The same can be done for actions with the `:button_html` option:

```erb
  <%= semantic_form_for @post do |f| %>
    ...
    <%= f.actions do %>
      <%= f.action :submit, :button_html => { :class => "primary", :disable_with => 'Wait...' } %>
    <% end %>
  <% end %>
```

Customize the HTML attributes for the `<li>` wrapper around every input with the `:wrapper_html` option hash. There's one special key in the hash: (`:class`), which will actually _append_ your string of classes to the existing classes provided by Formtastic (like `"required string error"`).

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs do %>
      <%= f.input :title, :wrapper_html => { :class => "important" } %>
      <%= f.input :body %>
      <%= f.input :description, :wrapper_html => { :style => "display:none;" } %>
    <% end %>
    ...
  <% end %>
```

Many inputs provide a collection of options to choose from (like `:select`, `:radio`, `:check_boxes`, `:boolean`). In many cases, Formtastic can find choices through the model associations, but if you want to use your own set of choices, the `:collection` option is what you want.  You can pass in an Array of objects, an array of Strings, a Hash... Throw almost anything at it! Examples:

```ruby
  f.input :authors, :as => :check_boxes, :collection => User.order("last_name ASC").all
  f.input :authors, :as => :check_boxes, :collection => current_user.company.users.active
  f.input :authors, :as => :check_boxes, :collection => [@justin, @kate]
  f.input :authors, :as => :check_boxes, :collection => ["Justin", "Kate", "Amelia", "Gus", "Meg"]
  f.input :author,  :as => :select,      :collection => Author.all
  f.input :author,  :as => :select,      :collection => Author.pluck(:first_name, :id)
  f.input :author,  :as => :select,      :collection => Author.pluck(Arel.sql("CONCAT(`first_name`, ' ', `last_name`)"), :id)
  f.input :author,  :as => :select,      :collection => Author.your_custom_scope_or_class_method
  f.input :author,  :as => :select,      :collection => { @justin.name => @justin.id, @kate.name => @kate.id }
  f.input :author,  :as => :select,      :collection => ["Justin", "Kate", "Amelia", "Gus", "Meg"]
  f.input :author,  :as => :radio,       :collection => User.all
  f.input :author,  :as => :radio,       :collection => [@justin, @kate]
  f.input :author,  :as => :radio,       :collection => { @justin.name => @justin.id, @kate.name => @kate.id }
  f.input :author,  :as => :radio,       :collection => ["Justin", "Kate", "Amelia", "Gus", "Meg"]
  f.input :admin,   :as => :radio,       :collection => ["Yes!", "No"]
  f.input :book_id, :as => :select,      :collection => Hash[Book.all.map{|b| [b.name,b.id]}]
  f.input :fav_book,:as => :datalist   , :collection => Book.pluck(:name)
```


## The Available Inputs

The Formtastic input types:

* `:select` - a select menu. Default for ActiveRecord associations: `belongs_to`, `has_many`, and `has_and_belongs_to_many`.
* `:check_boxes` - a set of check_box inputs. Alternative to `:select` for ActiveRecord-associations: `has_many`, and has_and_belongs_to_many`.
* `:radio` - a set of radio inputs. Alternative to `:select` for ActiveRecord-associations: `belongs_to`.
* `:time_zone` - a select input. Default for column types: `:string` with name matching `"time_zone"`.
* `:password` - a password input. Default for column types: `:string` with name matching `"password"`.
* `:text` - a textarea. Default for column types: `:text`.
* `:date_select` - a date select. Default for column types: `:date`.
* `:datetime_select` - a date and time select. Default for column types: `:datetime` and `:timestamp`.
* `:time_select` - a time select. Default for column types: `:time`.
* `:boolean` - a checkbox. Default for column types: `:boolean`.
* `:string` - a text field. Default for column types: `:string`.
* `:number` - a text field (just like string). Default for  column types: `:integer`, `:float`, and `:decimal`.
* `:file` - a file field. Default for file-attachment attributes matching: [paperclip](https://github.com/thoughtbot/paperclip) or [attachment_fu](https://github.com/technoweenie/attachment_fu).
* `:country` - a select menu of country names. Default for column types: `:string` with name `"country"` - requires a *country_select* plugin to be installed.
* `:email` - a text field (just like string). Default for columns with name matching `"email"`. New in HTML5. Works on some mobile browsers already.
* `:url` - a text field (just like string). Default for columns with name matching `"url"`. New in HTML5. Works on some mobile browsers already.
* `:phone` - a text field (just like string). Default for columns with name matching `"phone"` or `"fax"`. New in HTML5.
* `:search` - a text field (just like string). Default for columns with name matching `"search"`. New in HTML5. Works on Safari.
* `:hidden` - a hidden field. Creates a hidden field (added for compatibility).
* `:range` - a slider field.
* `:datalist` - a text field with a accompanying [datalist tag](https://developer.mozilla.org/en/docs/Web/HTML/Element/datalist) which provides options for autocompletion

The comments in the code are pretty good for each of these (what it does, what the output is, what the options are, etc.) so go check it out.


## Delegation for label lookups

Formtastic decides which label to use in the following order:

```
  1. :label             # :label => "Choose Title"
  2. Formtastic i18n    # if either :label => true || i18n_lookups_by_default = true (see Internationalization)
  3. Activerecord i18n  # if localization file found for the given attribute
  4. label_str_method   # if nothing provided this defaults to :humanize but can be set to a custom method
```

## Internationalization (I18n)

### Basic Localization

Formtastic has some neat I18n-features. ActiveRecord object names and attributes are, by default, taken from calling `@object.human_name` and `@object.human_attribute_name(attr)` respectively. There are a few words specific to Formtastic that can be translated. See `lib/locale/en.yml` for more information.

Basic localization (labels only, with ActiveRecord):

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs do %>
      <%= f.input :title %>        # => :label => I18n.t('activerecord.attributes.user.title')    or 'Title'
      <%= f.input :body %>         # => :label => I18n.t('activerecord.attributes.user.body')     or 'Body'
      <%= f.input :section %>      # => :label => I18n.t('activerecord.attributes.user.section')  or 'Section'
    <% end %>
  <% end %>
```

*Note:* This is perfectly fine if you just want your labels/attributes and/or models to be translated using *ActiveRecord I18n attribute translations*, and you don't use input hints and legends. But what if you do? And what if you don't want same labels in all forms?

### Enhanced Localization (Formtastic I18n API)

Formtastic supports localized *labels*, *hints*, *legends*, *actions* using the I18n API for more advanced usage. Your forms can now be DRYer and more flexible than ever, and still fully localized. This is how:

*1. Enable I18n lookups by default (`config/initializers/formtastic.rb`):*

```ruby
  Formtastic::FormBuilder.i18n_lookups_by_default = true
```

*2. Add some label-translations/variants (`config/locales/en.yml`):*

```yml
  en:
    formtastic:
      titles:
        post_details: "Post details"
      labels:
        post:
          title: "Your Title"
          body: "Write something..."
          edit:
            title: "Edit title"
      hints:
        post:
          title: "Choose a good title for your post."
          body: "Write something inspiring here."
      placeholders:
        post:
          title: "Title your post"
          slug: "Leave blank for an automatically generated slug"
        user:
          email: "you@yours.com"
      actions:
        create: "Create my %{model}"
        update: "Save changes"
        reset: "Reset form"
        cancel: "Cancel and go back"
        dummie: "Launch!"
```

*3. ...and now you'll get:*

```erb
  <%= semantic_form_for Post.new do |f| %>
    <%= f.inputs do %>
      <%= f.input :title %>      # => :label => "Choose a title...", :hint => "Choose a good title for your post."
      <%= f.input :body %>       # => :label => "Write something...", :hint => "Write something inspiring here."
      <%= f.input :section %>    # => :label => I18n.t('activerecord.attributes.user.section')  or 'Section'
    <% end %>
    <%= f.actions do %>
      <%= f.action :submit %>   # => "Create my %{model}"
    <% end %>
  <% end %>
```

*4. Localized titles (a.k.a. legends):*

_Note: Slightly different because Formtastic can't guess how you group fields in a form. Legend text can be set with first (as in the sample below) specified value, or :name/:title options - depending on what flavor is preferred._

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs :post_details do %>   # => :title => "Post details"
      # ...
    <% end %>
    # ...
<% end %>
```

*5. Override I18n settings:*

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs do %>
      <%= f.input :title %>      # => :label => "Choose a title...", :hint => "Choose a good title for your post."
      <%= f.input :body, :hint => false %>                 # => :label => "Write something..."
      <%= f.input :section, :label => 'Some section' %>    # => :label => 'Some section'
    <% end %>
    <%= f.actions do %>
      <%= f.action :submit, :label => :dummie %>         # => "Launch!"
    <% end %>
  <% end %>
```

If I18n-lookups is disabled, i.e.:

```ruby
  Formtastic::FormBuilder.i18n_lookups_by_default = false
```

...then you can enable I18n within the forms instead:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.inputs do %>
      <%= f.input :title, :label => true %>      # => :label => "Choose a title..."
      <%= f.input :body, :label => true %>       # => :label => "Write something..."
      <%= f.input :section, :label => true %>    # => :label => I18n.t('activerecord.attributes.user.section')  or 'Section'
    <% end %>
    <%= f.actions do %>
      <%= f.action :submit, :label => true %>    # => "Update %{model}" (if we are in edit that is...)
    <% end %>
  <% end %>
```

*6. Advanced I18n lookups*

For more flexible forms; Formtastic finds translations using a bottom-up approach taking the following variables in account:

* `MODEL`, e.g. "post"
* `ACTION`, e.g. "edit"
* `KEY/ATTRIBUTE`, e.g. "title", :my_custom_key, ...

...in the following order:

1. `formtastic.{titles,labels,hints,actions}.MODEL.ACTION.ATTRIBUTE` - by model and action
2. `formtastic.{titles,labels,hints,actions}.MODEL.ATTRIBUTE` - by model
3. `formtastic.{titles,labels,hints,actions}.ATTRIBUTE` - global default

...which means that you can define translations like this:

```yml
  en:
    formtastic:
      labels:
        title: "Title"  # Default global value
        article:
          body: "Article content"
        post:
          new:
            title: "Choose a title..."
            body: "Write something..."
          edit:
            title: "Edit title"
            body: "Edit body"
```

Values for `labels`/`hints`/`actions` are can take values: `String` (explicit value), `Symbol` (i18n-lookup-key relative to the current "type", e.g. actions:), `true` (force I18n lookup), `false` (force no I18n lookup). Titles (legends) can only take: `String` and `Symbol` - true/false have no meaning.

*7. Basic Translations*
If you want some basic translations, take a look on the [formtastic_i18n gem](https://github.com/timoschilling/formtastic_i18n).

## Semantic errors

You can show errors on base (by default) and any other attribute just by passing its name to the semantic_errors method:

```erb
  <%= semantic_form_for @post do |f| %>
    <%= f.semantic_errors :state %>
  <% end %>
```


## Modified & Custom Inputs

You can modify existing inputs, subclass them, or create your own from scratch. Here's the basic process:

* Run the input generator and provide your custom input name. For example, `rails generate formtastic:input hat_size`. This creates the file `app/inputs/hat_size_input.rb`. You can also provide namespace to input name like `rails generate formtastic:input foo/custom` or `rails generate formtastic:input Foo::Custom`, this will create the file `app/inputs/foo/custom_input.rb` in both cases.
* To use that input, leave off the word "input" in your `as` statement. For example, `f.input(:size, :as => :hat_size)`

Specific examples follow.

### Changing Existing Input Behavior

To modify the behavior of `StringInput`, subclass it in a new file, `app/inputs/string_input.rb`:

```ruby
  class StringInput < Formtastic::Inputs::StringInput
    def to_html
      puts "this is my modified version of StringInput"
      super
    end
  end
```

Another way to modify behavior is by using the input generator:
```shell
$ rails generate formtastic:input string --extend
```

This generates the file `app/inputs/string_input.rb` with its respective content class.

You can use your modified version with `:as => :string`.

### Creating New Inputs Based on Existing Ones

To create your own new types of inputs based on existing inputs, the process is similar. For example, to create `FlexibleTextInput` based on `StringInput`, put the following in `app/inputs/flexible_text_input.rb`:

```ruby
  class FlexibleTextInput < Formtastic::Inputs::StringInput
    def input_html_options
      super.merge(:class => "flexible-text-area")
    end

    def options
      super.merge(hint: 'This is a flexible text area')
    end
  end
```

You can also extend existing input behavior by using the input generator:

```shell
$ rails generate formtastic:input FlexibleText --extend string
```

This generates the file `app/inputs/flexible_text_input.rb` with its respective content class.

You can use your new input with `:as => :flexible_text`.

### Creating New Inputs From Scratch

To create a custom `DatePickerInput` from scratch, put the following in `app/inputs/date_picker_input.rb`:

```ruby
  class DatePickerInput
    include Formtastic::Inputs::Base
    def to_html
      # ...
    end
  end
```

You can use your new input with `:as => :date_picker`.


## Dependencies

There are none other than Rails itself, but...

* If you want to use the `:country` input, you'll need to install the [country-select plugin](https://github.com/countries/country_select) (or any other country_select plugin with the same API).
* There are a bunch of development dependencies if you plan to contribute to Formtastic


## How to contribute

See `CONTRIBUTING.md`


## Project Info

Formtastic was created by [Justin French](https://www.justinfrench.com) with contributions from around 180 awesome developers. Run `git shortlog -n -s` to see the awesome.

The project is hosted on Github: [https://github.com/formtastic/formtastic](https://github.com/formtastic/formtastic), where your contributions, forkings, comments, issues and feedback are greatly welcomed.

Copyright (c) 2007-2025, released under the MIT license.

