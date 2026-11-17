# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class ArticleWidget < Prawn::Widget
  renders_one :title, -> {}
  renders_one :body, -> {}

  option :featured, default: -> { false }

  def call
    pdf.push "<article#{' featured' if featured}>"

    draw_wrapped('title', title)
    draw_wrapped('body', body)

    pdf.push '</article>'
  end

  private

  def draw_wrapped(tag, slot)
    pdf.push("<#{tag}>")
    slot&.draw
    pdf.push("</#{tag}>")
  end
end
