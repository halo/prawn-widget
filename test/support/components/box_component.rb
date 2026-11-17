# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class BoxComponent < Prawn::Widget
  renders_one :title
  renders_one :description

  def call
    pdf.push '<<'

    title&.draw
    description&.draw

    pdf.push '>>'
  end
end
