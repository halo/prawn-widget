# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class PrawnSlotTest < Megatest::Test
  test '#draw - with block content only - runs the block' do
    drawn = []
    widget = StreetWidget.new

    slot = widget.with_car do
      drawn.push('Ford')
    end

    slot.draw

    assert_equal ['Ford'], drawn
  end

  test '#draw - with widget instance - renders the instance' do
    pdf = []

    BlogWidget.new.render_in(pdf) do |blog|
      blog.with_article(featured: true) do |article|
        article.with_title do
          pdf.push 'Breaking news'
        end
      end
    end

    assert_equal ['<blog>', '<article featured>', '<title>', 'Breaking news', '</title>',
                  '<body>', '</body>', '</article>', '</blog>'],
                 pdf
  end

  test '#draw - with empty slot - draws nothing' do
    widget = StreetWidget.new

    slot = Prawn::Widgets::Slot.new(widget)

    assert_nil slot.draw
  end

  test '#method_missing - with widget instance - reaches the widget' do
    widget = BlogWidget.new

    slot = widget.with_article(featured: true)

    assert_equal true, slot.featured
  end

  test '#method_missing - with block content only - raises an error' do
    widget = StreetWidget.new

    slot = widget.with_car do
      'Ford'
    end

    assert_raises(NoMethodError) { slot.honk }
  end

  test '#respond_to? - with widget instance - answers for widget methods' do
    widget = BlogWidget.new

    slot = widget.with_article(featured: true)

    assert_respond_to slot, :featured
    refute_respond_to slot, :honk
  end
end
