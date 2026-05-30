module ApplicationHelper
  # Merge in the attributes that tell browser password managers (1Password,
  # LastPass) to leave a field alone — so non-credential fields like a pet's
  # "Name" or a vet's "Email" don't trigger autofill suggestions OR the
  # "save to 1Password?" prompt on submit. The managers only reliably honor
  # these on the input itself (not the <form>), so we apply them per field:
  #
  #   <%= form.text_field :name, pm_off(placeholder: "e.g. Scout", class: "...") %>
  #
  # deep_merge preserves any data: hooks already on the field (e.g. the avatar
  # field's Stimulus image-preview targets).
  def pm_off(opts = {})
    opts.deep_merge(
      autocomplete: "off",
      data: { "1p-ignore": "true", lpignore: "true" }
    )
  end

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
