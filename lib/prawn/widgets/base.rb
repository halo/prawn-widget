# frozen_string_literal: true

# SPDX-License-Identifier: MIT
module Prawn
  module Widgets
    # Adaptation of https://github.com/ViewComponent/view_component/blob/main/lib/view_component/slotable.rb
    # But without action view and caching.
    # ViewComponent adaptation, MIT (c) 2019 GitHub.
    class Base
      include ::Calls

      # Widgets are instantiated with `.new`, not `.call`.
      # The `calls` gem makes `.new` private.
      # We make `.new` public again so widgets render via `Widget.new.render_in(pdf)`.
      public_class_method :new

      class_attribute :registered_slots
      self.registered_slots = {}

      def self.renders_one(slot_name, callable = nil)
        define_method(:"with_#{slot_name}") do |*args, **kwargs, &block|
          set_slot(slot_name, *args, **kwargs, &block)
        end

        define_method(slot_name) do
          get_slot(slot_name)
        end

        register_slot(slot_name, collection: false, callable:)
      end

      def self.renders_many(slot_name, callable = nil)
        singular_name = ActiveSupport::Inflector.singularize(slot_name)

        # Define setter for singular names
        # e.g. `renders_many :items` allows fetching all tabs with
        # `widget.tabs` and setting a tab with `widget.with_tab`
        define_method(:"with_#{singular_name}") do |*args, **kwargs, &block|
          set_slot(slot_name, *args, **kwargs, &block)
        end

        # Instantiates and and adds multiple slots forwarding the first
        # argument to each slot constructor
        define_method(:"with_#{slot_name}") do |collection_args = nil, &block|
          set_many_slots(slot_name, collection_args, &block)
        end

        define_method(slot_name) do
          get_slot(slot_name)
        end

        register_slot(slot_name, collection: true, callable:)
      end

      # Clone slot configuration into child class
      # see #test_slots_pollution
      def self.inherited(child)
        child.registered_slots = registered_slots.clone
        super
      end

      # PRIVATE

      def self.register_slot(slot_name, collection:, callable:)
        # Setup basic slot data
        slot = { collection: }
        # If callable responds to `render_in`, we set it on the slot as a renderable
        if callable.respond_to?(:method_defined?) && callable.method_defined?(:render_in)
          slot[:renderable] = callable

        elsif callable
          # If slot does not respond to `render_in`, we assume it's a proc,
          # define a method, and save a reference to it to call when setting
          method_name = :"_call_#{slot_name}"
          define_method method_name, &callable
          slot[:renderable_function] = instance_method(method_name)
        end

        # Register the slot on the widget
        registered_slots[slot_name] = slot
      end
      private_class_method :register_slot

      def set_slot(slot_name, *, **, &block)
        slot_definition = self.class.registered_slots[slot_name]

        slot = Slot.new(self)

        # Passing the block to the sub-widget wrapper like this has two
        # benefits:
        #
        # 1. If this is a `content_area` style sub-widget, we will render the
        # block via the `slot`
        #
        # 2. Since we have to pass block content to widgets when calling
        # `render`, evaluating the block here would require us to call
        # `view_context.capture` twice, which is slower
        slot._content_block = block if block_given?

        build_slot_widget(slot_definition, slot, *, **, &block)

        @_set_slots ||= {}

        if slot_definition[:collection]
          @_set_slots[slot_name] ||= []
          @_set_slots[slot_name].push(slot)
        else
          @_set_slots[slot_name] = slot
        end

        slot
      end

      # Creates the renderable for a slot, if the slot declares one.
      # Plain slots without a callable only carry the content block.
      def build_slot_widget(slot_definition, slot, *, **, &)
        if slot_definition[:renderable]
          # If class
          slot._widget_instance = slot_definition[:renderable].new(*, **)

        elsif slot_definition[:renderable_function]
          # If passed a lambda
          # Use `bind(self)` to ensure lambda is executed in the context of the
          # current widget. This is necessary to allow the lambda to access helper
          # methods like `content_tag` as well as parent widget state.
          renderable_value = slot_definition[:renderable_function].bind(self).call(*, **, &)

          # Function calls can return widgets, so if it's a widget handle it specially
          slot._widget_instance = renderable_value if renderable_value.respond_to?(:render_in)
        end
      end

      # Backwards compatibility for the `prawn-component` days.
      alias build_slot_component build_slot_widget

      def get_slot(slot_name)
        @_set_slots ||= {}

        # Unset slots read as empty, so getters never return stale state.
        # Collections read as an empty list, single slots read as nil.
        @_set_slots.fetch(slot_name) do
          self.class.registered_slots[slot_name][:collection] ? [] : nil
        end
      end

      def render_in(pdf)
        @pdf = pdf

        # We have to yield eventually, because otherwise the widgets' block would not be executed.
        # Also, we have to yield before trying to draw subwidgets (because they are set up by executing the block).
        # It's unintuitive to leave that up to the developer to figure out in all their widgets.
        # So, we keep things simple and always yield right away, so everything is set up properly.
        # The downside is that this forces `renders_one` subwidgets instead of simply `yield` to render the block.
        yield self if block_given?

        call if render?
      end

      # However, we also provide this custom method to have the widget handle the `yield` itself.
      def call_in(pdf, &)
        @pdf = pdf

        call(&) if render?
      end

      private

      # Adds one slot per entry, forwarding each entry to the slot constructor.
      def set_many_slots(slot_name, collection_args, &)
        collection_args.map do |collection_item_args|
          if collection_item_args.respond_to?(:to_hash)
            set_slot(slot_name, **collection_item_args, &)
          else
            set_slot(slot_name, *collection_item_args, &)
          end
        end
      end

      attr_reader :pdf

      # Override this with logic in your widget.
      def render?
        true
      end
    end
  end
end
