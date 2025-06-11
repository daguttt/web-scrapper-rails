ActionView::Base.field_error_proc = proc do |html_tag|
  # This will avoid wrapping field with erros with a `<div class="field_with_errors">` tag
  html_tag.html_safe # rubocop:disable Rails/OutputSafety
end
