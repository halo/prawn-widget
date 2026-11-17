# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class BlogWidget < Prawn::Widget
  renders_many :articles, ArticleWidget

  def call
    pdf.push '<blog>'

    articles.each(&:draw)

    pdf.push '</blog>'
  end
end
