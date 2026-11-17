# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class PrawnSlotTest < Megatest::Test
  test '#draw - with block content only - runs the block' do
    drawn = []
    component = StreetComponent.new

    slot = component.with_car do
      drawn.push('Ford')
    end

    slot.draw

    assert_equal ['Ford'], drawn
  end

  test '#draw - with component instance - renders the instance' do
    pdf = []

    BlogComponent.new.render_in(pdf) do |blog|
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
    component = StreetComponent.new

    slot = Prawn::Components::Slot.new(component)

    assert_nil slot.draw
  end

  test '#method_missing - with component instance - reaches the component' do
    component = BlogComponent.new

    slot = component.with_article(featured: true)

    assert_equal true, slot.featured
  end

  test '#method_missing - with block content only - raises an error' do
    component = StreetComponent.new

    slot = component.with_car do
      'Ford'
    end

    assert_raises(NoMethodError) { slot.honk }
  end

  test '#respond_to? - with component instance - answers for component methods' do
    component = BlogComponent.new

    slot = component.with_article(featured: true)

    assert_respond_to slot, :featured
    refute_respond_to slot, :honk
  end
end
