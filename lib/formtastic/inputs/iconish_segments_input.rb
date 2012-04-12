module Formtastic
  module Inputs

    # Outputs a simple `<label> with input groups `<div class="iconish-segments-controls">` wrapped in the standard
    # `<li>` wrapper. Input groups provide an easy way to give more context to your inputs. Context is given by
    # appending and/or prepending `<span class="add-on">` to `<input type="text">`. If you need to render a button
    # next to your field just pass in a code block with `:input_append => lambda { button_tag }`. This will render
    # `<button>` instead of `<span class="add-on">`. It is also possible to render an image inside
    # `<span class="add-on">` with `:input_prepend => lambda { image_tag("icon.png") }`. This will output a simple
    # `<img />` wrapped in the default `<span class="add-on"` wrapper.
    #
    # @example Full form context and output
    #
    #  <= semantic_form_for(@bank_account) do |f| %>
    #    <%= f.inputs do %>
    #      <%= f.input :money, :as => :iconish_segments, :input_prepend => '$', :input_append => '.00' %>
    #    <% end %>
    #  <% end %>
    #
    #  <form...>
    #    <fieldset...>
    #      <ol>
    #        <li... class="iconish_segments">
    #          <label... for="bank_account_money"><Money/label>
    #          <div class="iconish-segments-controls input-prepend input-append">
    #            <span class="add-on">$</span>
    #            <input type="text" id="bank_account_money" name="bank_account[money]" />
    #            <span class="add-on">.00</span>
    #          </div>
    #        </li>
    #      </ol>
    #    </fieldset>
    #  </form>
    #
    # @example Pass in a block
    #
    #  <= semantic_form_for(@bank_account) do |f| %>
    #    <%= f.inputs do %>
    #      <%= f.input :money, :as => :iconish_segments, :input_prepend => lambda { image_tag("money.png") } %>
    #    <% end %>
    #  <% end %>
    #
    #  <form...>
    #    <fieldset...>
    #      <ol>
    #        <li... class="iconish_segments">
    #          <label... for="bank_account_money"><Money/label>
    #          <div class="iconish-segments-controls input-prepend">
    #            <span class="add-on">
    #              <img src="/images/money.png" alt="Money" />
    #            </span>
    #            <input type="text" id="bank_account_money" name="bank_account[money]" />
    #          </div>
    #        </li>
    #      </ol>
    #    </fieldset>
    #  </form>
    #
    # @example Append with button
    #
    #  <= semantic_form_for(@user) do |f| %>
    #    <%= f.inputs do %>
    #      <%= f.input :mobile, :as => :iconish_segments, :input_append => lambda { button_tag("Send", :disable_with => "Sending...") } %>
    #    <% end %>
    #  <% end %>
    #
    #  <form...>
    #    <fieldset...>
    #      <ol>
    #        <li... class="iconish_segments">
    #          <label... for="user_mobile"><Money/label>
    #          <div class="iconish-segments-controls input-append">
    #            <input type="text" id="user_mobile" name="user[mobile]" />
    #            <button data-disable-with="Sending..." name="button" type="submit">Send</button>
    #          </div>
    #        </li>
    #      </ol>
    #    </fieldset>
    #  </form>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.
    class IconishSegmentsInput
      include Base
      include Base::Stringish

      def to_html
        input_wrapping do
          label_html <<
          iconish_segments_controls
        end
      end

      def iconish_segments_controls
        iconish_segments_wrapping do
          builder.text_field(method, input_html_options)
        end
      end

      def iconish_segments_wrapping(&block)
        template.content_tag(:div,
                             iconish_segments(&block),
                             iconish_segments_wrapping_html_options
        )
      end

      def iconish_segments(&block)
        [add_on_prepend, template.capture(&block), add_on_append].compact.join("\n").html_safe
      end

      def iconish_segments_wrapping_html_options
        {:class => iconish_segments_wrapping_classes}
      end

      def iconish_segments_wrapping_classes
        opt = options
        classes = ['iconish-segments-controls']
        classes << 'input-prepend' if opt[:input_prepend]
        classes << 'input-append' if opt[:input_append]
        classes.join(' ')
      end

      def add_on_prepend
        add_on_from_options(:input_prepend)
      end

      def add_on_append
        add_on_from_options(:input_append)
      end

      def add_on_from_options(key)
        if opt = options[key]
          content = if opt.is_a?(Proc)
                      opt.call
                    else
                      opt.to_s
                    end
          add_on(content)
        end
      end

      def add_on(content)
        if content =~ /^<button.*>/
          content
        else
          template.content_tag(:span, content, :class => 'add-on')
        end
      end
    end

  end
end
