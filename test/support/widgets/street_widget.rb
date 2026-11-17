# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class StreetWidget < Prawn::Widget
  renders_many :cars

  def call
    cars.each do |car|
      pdf.push 'Car:'
      car.draw
    end
  end
end
