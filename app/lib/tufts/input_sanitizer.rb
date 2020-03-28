require 'byebug'
module Tufts
  class InputSanitizer
    # Remove any markup except the elements explicitly allowed here
    # rubocop:disable Metrics/MethodLength
    def self.sanitize(raw_input)
      clean_html = Sanitize.clean(
        CGI.unescapeHTML(raw_input),
        elements: [
          'a',
          'b',
          'blockquote',
          'code',
          'em',
          'i',
          'p',
          'span',
          'strong',
          'style',
          'sup'
        ],
        attributes: {
          'p' => ['style'],
          'span' => ['style'],
          'a' => ['href']
        },
        css: {
          properties: [
            'font-family',
            'margin',
            'padding',
            'text-align',
            'text-decoration',
            'width'
          ]
        }
      )
      CGI.unescapeHTML(clean_html.to_s)
    end
  end
end
