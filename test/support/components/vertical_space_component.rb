# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class VerticalSpaceComponent < Prawn::Component
  def call
    pdf.push 'Up here'
    yield
    pdf.push 'Down there'
  end
end
