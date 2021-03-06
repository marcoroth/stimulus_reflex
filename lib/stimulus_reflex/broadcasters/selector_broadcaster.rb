# frozen_string_literal: true

module StimulusReflex
  class SelectorBroadcaster < Broadcaster
    def broadcast(_, data = {})
      morphs.each do |morph|
        selectors, html = morph
        updates = selectors.is_a?(Hash) ? selectors : Hash[selectors, html]
        updates.each do |key, value|
          html = reflex.render(key) if key.is_a?(ActiveRecord::Base) && value.nil?
          html = reflex.render_collection(key) if key.is_a?(ActiveRecord::Relation) && value.nil?
          html ||= value
          fragment = Nokogiri::HTML.fragment(html.to_s)
          selector = key.is_a?(ActiveRecord::Base) || key.is_a?(ActiveRecord::Relation) ? reflex.dom_id(key) : key.to_s
          match = fragment.at_css(selector)
          if match.present?
            operations << [selector, :morph]
            cable_ready.morph(
              selector: selector,
              html: match.inner_html(save_with: Broadcaster::DEFAULT_HTML_WITHOUT_FORMAT),
              payload: payload,
              children_only: true,
              permanent_attribute_name: permanent_attribute_name,
              stimulus_reflex: data.merge({
                morph: to_sym
              })
            )
          else
            operations << [selector, :inner_html]
            cable_ready.inner_html(
              selector: selector,
              html: fragment.to_html,
              payload: payload,
              stimulus_reflex: data.merge({
                morph: to_sym
              })
            )
          end
        end
      end

      cable_ready.broadcast
      morphs.clear
    end

    def morphs
      @morphs ||= []
    end

    def append_morph(selectors, html)
      morphs << [selectors, html]
    end

    def to_sym
      :selector
    end

    def selector?
      true
    end

    def to_s
      "Selector"
    end
  end
end
