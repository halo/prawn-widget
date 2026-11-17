# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class HelloWorldComponent < Prawn::Widget
  def call
    pdf.push 'Hello World!'
  end
end
