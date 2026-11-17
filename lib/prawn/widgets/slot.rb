# frozen_string_literal: true

# SPDX-License-Identifier: MIT
module Prawn
  module Widgets
    # Adaptation of https://github.com/ViewComponent/view_component/blob/main/lib/view_component/slot.rb
    # But without string capturing.
    # ViewComponent adaptation, MIT (c) 2019 GitHub.
    class Slot
      attr_writer :_widget_instance, :_content_block

      def initialize(parent)
        @parent = parent
      end

      # This is what `to_s` is in the view_component gem.
      # It renders the content into the view context (that is, the PDF)
      def draw
        pdf = @parent.send(:pdf)

        if defined?(@_widget_instance)
          @_widget_instance.render_in(pdf, &@_content_block)

        elsif defined?(@_content_block)
          @_content_block.call
        end
      end

      # Give a widget access to its slot instances through this wrapper.
      def method_missing(symbol, *, &)
        @_widget_instance.public_send(symbol, *, &)
      end

      def respond_to_missing?(symbol, include_all = false)
        defined?(@_widget_instance) && @_widget_instance.respond_to?(symbol, include_all)
      end
    end
  end
end
