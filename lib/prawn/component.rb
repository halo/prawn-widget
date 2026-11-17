# frozen_string_literal: true

# SPDX-License-Identifier: MIT
require 'calls'
require 'active_support/core_ext/class/attribute'
require 'active_support/inflector/methods'

require 'prawn/components/version'
require 'prawn/components/base'
require 'prawn/components/slot'

module Prawn
  class Component < ::Prawn::Components::Base
  end
end
