# frozen_string_literal: true

module StimulusReflex
  class PageBroadcaster < Broadcaster
    def broadcast(selectors, data)
      reflex.controller.process reflex.params[:action]
      fragment = StimulusReflex::HTML::Document.new(reflex.controller.response.body)

      return if fragment.empty?

      selectors = selectors.map { |s| [s, fragment.match(s)] }.filter { |s, f| f.present? }
      selectors.each do |selector, selector_fragment|
        operations << [selector, StimulusReflex.config.morph_operation]
        cable_ready.send StimulusReflex.config.morph_operation, {
          selector: selector,
          html: selector_fragment.inner_html,
          outer_html: selector_fragment.outer_html,
          payload: payload,
          children_only: true,
          permanent_attribute_name: permanent_attribute_name,
          stimulus_reflex: data.merge(morph: to_sym)
        }
      end
      cable_ready.broadcast
    end

    def to_sym
      :page
    end

    def page?
      true
    end

    def to_s
      "Page"
    end
  end
end
