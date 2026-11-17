# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class ButtonWidget < Prawn::Widget
  renders_one :title

  def call
    pdf.push '<<'

    title&.draw

    pdf.push '>>'
  end
end
