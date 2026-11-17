# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class HiddenSlotComponent < Prawn::Widget
  renders_one :secret

  def call; end
end

class RequiredOptionSlotComponent < Prawn::Widget
  option :message

  def call
    pdf.push message
  end
end

class SkippedSlotComponent < Prawn::Widget
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
    component = BoxComponent.new

    assert_nil component.title
  end

  test '.renders_one - with slot set - getter is a slot' do
    component = BoxComponent.new

    slot = component.with_title { 'TITLE' }

    assert_instance_of Prawn::Components::Slot, slot
    assert_instance_of Prawn::Components::Slot, component.title
  end

  test '.renders_one - with bare getter - emits no warning' do
    component = BoxComponent.new

    _, stderr = capture_io do
      component.title
    end

    assert_empty stderr
  end

  test '.renders_many - with no slots set - getter is empty' do
    component = StreetComponent.new

    assert_equal [], component.cars
  end

  test '.renders_many - with slots set - getter holds each slot' do
    component = StreetComponent.new

    component.with_car { 'Ford' }
    component.with_car { 'Mercedes' }

    assert_equal 2, component.cars.length
  end

  test '.renders_many - with bulk setter - sets one slot per entry' do
    component = StreetComponent.new

    slots = component.with_cars(%w[Ford Mercedes])

    assert_equal 2, slots.length
    assert_equal 2, component.cars.length
  end

  test '.inherited - with slot added on a child - parent stays unchanged' do
    child_class = Class.new(HiddenSlotComponent) do
      renders_one :extra
    end

    child = child_class.new

    child.with_extra { 'shh' }

    assert_instance_of Prawn::Components::Slot, child.extra
    assert child_class.registered_slots.key?(:extra)
    refute HiddenSlotComponent.registered_slots.key?(:extra)
    refute_respond_to HiddenSlotComponent.new, :extra
  end

  test '.option - with missing required option - raises an error' do
    assert_raises(KeyError) { RequiredOptionSlotComponent.new }
  end

  test '.option - with unknown option - raises an error' do
    assert_raises(KeyError) { RequiredOptionSlotComponent.new(bogus: true) }
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

    SkippedSlotComponent.new.render_in(pdf) do |skipped|
      skipped.with_title { pdf.push 'TITLE' }
    end

    assert_empty pdf
  end
end
