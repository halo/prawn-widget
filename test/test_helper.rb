# SPDX-License-Identifier: MIT
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'megatest/autorun'
require 'fileutils'
require 'prawn'
require 'prawn/component'

Dir[File.expand_path('support/components/*.rb', __dir__)].each do |support_file|
  require support_file
end
