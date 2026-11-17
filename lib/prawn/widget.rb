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
end
