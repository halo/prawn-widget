# frozen_string_literal: true

# SPDX-License-Identifier: MIT
require 'calls'
require 'active_support/core_ext/class/attribute'
require 'active_support/inflector/methods'

require 'prawn/widgets/version'
require 'prawn/widgets/base'
require 'prawn/widgets/slot'

module Prawn
  class Widget < ::Prawn::Widgets::Base
  end

  # Backwards compatibility for the `prawn-component` days.
  Components = Widgets unless const_defined?(:Components)
end
