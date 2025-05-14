# frozen_string_literal: true

module Tightknit
  # The Utils module contains utility classes for various helper functions.
  module Utils
    # The HtmlFormatter class provides utilities for converting Slack blocks to HTML.
    # This is useful for displaying event descriptions that are stored in Slack block format.
    #
    # @example Convert Slack blocks to HTML
    #   blocks = [
    #     {
    #       type: "rich_text",
    #       elements: [
    #         {
    #           type: "rich_text_section",
    #           elements: [
    #             {
    #               type: "text",
    #               text: "Hello, world!"
    #             }
    #           ]
    #         }
    #       ]
    #     }
    #   ]
    #
    #   html = Tightknit::Utils::HtmlFormatter.slack_blocks_to_html(blocks)
    #   # => "<p class='mb-4'>Hello, world!</p>"
    #
    class HtmlFormatter
      class << self
        # Convert Slack blocks to HTML
        #
        # This method takes an array of Slack blocks and converts them to HTML.
        # It supports rich text sections, lists, and various text styles.
        #
        # @param blocks [Array] Slack blocks to convert
        # @return [String] HTML representation of the Slack blocks
        def slack_blocks_to_html(blocks)
          return "" unless blocks.is_a?(Array)

          html = ""

          blocks.each do |block|
            next unless block.is_a?(Hash) && block[:type] == "rich_text" && block[:elements].is_a?(Array)

            block[:elements].each do |element|
              if element[:type] == "rich_text_section" && element[:elements].is_a?(Array)
                # Add a paragraph with margin for spacing
                html += "<p class='mb-4'>"
                element[:elements].each do |text_element|
                  processed_text = process_text_element(text_element)
                  # Replace newlines with <br> tags for proper line breaks
                  html += processed_text.to_s.gsub("\n", "<br>")
                end
                html += "</p>"
              elsif element[:type] == "rich_text_list" && element[:elements].is_a?(Array)
                # Add margin before and after lists
                if element[:style] == "bullet"
                  html += "<ul class='list-disc pl-5 my-4'>"
                  element[:elements].each do |list_item|
                    html += "<li class='mb-2'>"
                    if list_item[:elements].is_a?(Array)
                      list_item[:elements].each do |item_element|
                        processed_text = process_text_element(item_element)
                        html += processed_text.to_s.gsub("\n", "<br>")
                      end
                    end
                    html += "</li>"
                  end
                  html += "</ul>"
                elsif element[:style] == "ordered"
                  html += "<ol class='list-decimal pl-5 my-4'>"
                  element[:elements].each do |list_item|
                    html += "<li class='mb-2'>"
                    if list_item[:elements].is_a?(Array)
                      list_item[:elements].each do |item_element|
                        processed_text = process_text_element(item_element)
                        html += processed_text.to_s.gsub("\n", "<br>")
                      end
                    end
                    html += "</li>"
                  end
                  html += "</ol>"
                end
              end
            end
          end

          html
        end

        private

        # Process a text element from Slack blocks
        #
        # This method takes a text element from Slack blocks and converts it to HTML.
        # It supports various text styles like bold, italic, strikethrough, and code.
        #
        # @param element [Hash] Text element to process
        # @return [String] HTML representation of the text element
        def process_text_element(element)
          return "" unless element.is_a?(Hash)

          if element[:type] == "text"
            text = element[:text].to_s

            if element[:style]
              if element[:style][:bold]
                return "<strong>#{text}</strong>"
              elsif element[:style][:italic]
                return "<em>#{text}</em>"
              elsif element[:style][:strike]
                return "<del>#{text}</del>"
              elsif element[:style][:code]
                return "<code>#{text}</code>"
              end
            end

            return text
          elsif element[:type] == "link"
            return "<a href='#{element[:url]}' target='_blank' class='text-primary hover:underline'>#{element[:text]}</a>"
          end

          ""
        end
      end
    end
  end
end
