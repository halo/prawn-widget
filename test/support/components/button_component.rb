# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class ButtonComponent < Prawn::Component
  renders_one :title

  def call
    pdf.push '<<'

    title&.draw

    pdf.push '>>'
  end
end
