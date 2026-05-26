module ApplicationHelper
  # Inline, per-field validation message styled like Bootstrap's .invalid-feedback
  # (red text + an exclamation icon), rendered directly under the field. Returns
  # nil when the attribute has no errors, so it can be dropped after every input.
  #
  # `d-block` forces it visible: Rails wraps an errored field in a
  # `.field_with_errors` div, which breaks Bootstrap's default
  # ".is-invalid ~ .invalid-feedback" sibling rule — so we show it explicitly
  # rather than relying on that selector.
  def field_error(record, attribute)
    return if record.errors[attribute].blank?

    tag.div class: "invalid-feedback d-block" do
      safe_join([
        tag.i(class: "fa-solid fa-circle-exclamation me-1"),
        record.errors.full_messages_for(attribute).to_sentence
      ])
    end
  end
end
