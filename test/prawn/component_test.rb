# frozen_string_literal: true

# SPDX-License-Identifier: MIT
class PrawnComponentTest < Megatest::Test
  test '#render_in - with a simple call statement - draws the content' do
    pdf = []

    HelloWorldComponent.new.render_in(pdf)

    assert_equal ['Hello World!'], pdf
  end

  test '#render_in - with one slot - draws the block content' do
    pdf = []

    BoxComponent.new.render_in(pdf) do |box|
      box.with_title do
        pdf.push 'TITLE'
      end

      box.with_description do
        pdf.push 'DESCRIPTION'
      end
    end

    assert_equal ['<<', 'TITLE', 'DESCRIPTION', '>>'], pdf
  end

  test '#render_in - with many slots - draws each block' do
    pdf = []

    StreetComponent.new.render_in(pdf) do |street|
      street.with_car do
        pdf.push 'Ford'
      end

      street.with_car do
        pdf.push 'Mercedes'
      end
    end

    assert_equal ['Car:', 'Ford', 'Car:', 'Mercedes'], pdf
  end

  test '#render_in - with nested subcomponents - draws the whole tree' do
    pdf = []

    BlogComponent.new.render_in(pdf) do |blog|
      pdf.push 'Welcome to my Blog'

      blog.with_article do |article|
        article.with_title do
          pdf.push 'First Title'
        end

        article.with_body do
          pdf.push 'First Body'
        end
      end

      blog.with_article(featured: true) do |article|
        article.with_title do
          pdf.push 'Second Title'
        end

        article.with_body do
          pdf.push 'Second Body'
        end
      end
    end

    assert_equal 'Welcome to my Blog<blog><article><title>First Title</title>' \
                 '<body>First Body</body></article>' \
                 '<article featured><title>Second Title</title>' \
                 '<body>Second Body</body></article></blog>',
                 pdf.join
  end

  test '#call_in - with an explicit block - does not yield upfront' do
    pdf = []

    VerticalSpaceComponent.new.call_in(pdf) do
      pdf.push 'In between'
    end

    assert_equal ['Up here', 'In between', 'Down there'], pdf
  end
end
