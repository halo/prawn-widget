# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class HiddenSlotWidget < Prawn::Widget
  renders_one :secret

  def call; end
end

class RequiredOptionSlotWidget < Prawn::Widget
  option :message

  def call
    pdf.push message
  end
end

class SkippedSlotWidget < Prawn::Widget
  renders_one :title

  def call
    pdf.push 'called'
  end

  private

  def render?
    false
  end
end

class PrawnBaseTest < Megatest::Test
  test '.renders_one - with no slot set - getter is nil' do
    widget = BoxWidget.new

    assert_nil widget.title
  end

  test '.renders_one - with slot set - getter is a slot' do
    widget = BoxWidget.new

    slot = widget.with_title { 'TITLE' }

    assert_instance_of Prawn::Widgets::Slot, slot
    assert_instance_of Prawn::Widgets::Slot, widget.title
  end

  test '.renders_one - with bare getter - emits no warning' do
    widget = BoxWidget.new

    _, stderr = capture_io do
      widget.title
    end

    assert_empty stderr
  end

  test '.renders_many - with no slots set - getter is empty' do
    widget = StreetWidget.new

    assert_equal [], widget.cars
  end

  test '.renders_many - with slots set - getter holds each slot' do
    widget = StreetWidget.new

    widget.with_car { 'Ford' }
    widget.with_car { 'Mercedes' }

    assert_equal 2, widget.cars.length
  end

  test '.renders_many - with bulk setter - sets one slot per entry' do
    widget = StreetWidget.new

    slots = widget.with_cars(%w[Ford Mercedes])

    assert_equal 2, slots.length
    assert_equal 2, widget.cars.length
  end

  test '.inherited - with slot added on a child - parent stays unchanged' do
    child_class = Class.new(HiddenSlotWidget) do
      renders_one :extra
    end

    child = child_class.new

    child.with_extra { 'shh' }

    assert_instance_of Prawn::Widgets::Slot, child.extra
    assert child_class.registered_slots.key?(:extra)
    refute HiddenSlotWidget.registered_slots.key?(:extra)
    refute_respond_to HiddenSlotWidget.new, :extra
  end

  test '.option - with missing required option - raises an error' do
    assert_raises(KeyError) { RequiredOptionSlotWidget.new }
  end

  test '.option - with unknown option - raises an error' do
    assert_raises(KeyError) { RequiredOptionSlotWidget.new(bogus: true) }
  end

  test '.param - with default value - raises an error' do
    assert_raises(ArgumentError) do
      Class.new(Prawn::Widget) do
        param :name, default: -> { 'nobody' }
      end
    end
  end

  test '#render_in - with render? false - skips the call' do
    pdf = []

    SkippedSlotWidget.new.render_in(pdf) do |skipped|
      skipped.with_title { pdf.push 'TITLE' }
    end

    assert_empty pdf
  end
end
