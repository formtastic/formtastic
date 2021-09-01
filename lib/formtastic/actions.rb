# frozen_string_literal: true
module Formtastic
  module Actions
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Buttonish

    eager_autoload do
      autoload :InputAction
      autoload :LinkAction
      autoload :ButtonAction
    end
  end
end
