module ApplicationHelper
  # rubocop:disable Rails/OutputSafety
  def iconify_and_mark_safe(field, show_link = true)
    if field.is_a? Hash
      options = field[:config].separator_options || {}
      text = field[:value].to_sentence(options).html_safe
    else
      text = field.html_safe
    end
    # this block is only executed when a link is inserted;
    # if we pass text containing no links, it just returns text.
    auto_link(html_escape(text)) do |value|
      "<span class='glyphicon glyphicon-new-window'></span>#{('&nbsp;' + value) if show_link}"
    end
  end
end
