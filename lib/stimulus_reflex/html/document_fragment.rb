# forzen_string_literal: true

module StimulusReflex
  module HTML
    class DocumentFragment < Document
      def outer_html
        @document.to_html(save_with: DEFAULT_HTML_WITHOUT_FORMAT)
      end
      alias_method :to_html, :outer_html

      def inner_html
        @document.root&.inner_html(save_with: DEFAULT_HTML_WITHOUT_FORMAT) || ""
      end

      def parsing_class
        Nokogiri
      end
    end
  end
end
