# Use this setup block to configure all options available in SimpleForm.
class SimpleForm::Inputs::FileHackInput < SimpleForm::Inputs::FileInput
end

SimpleForm.setup do |config|
  config.button_class = 'btn btn-secondary'
  config.boolean_label_class = nil

  config.wrappers :vertical_form, tag: 'fieldset', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'

    b.wrapper tag: 'div' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :hint,  wrap_with: { tag: 'div', class: 'text-muted' }
    end
  end
  config.wrapper_mappings = {
    # check_boxes: :horizontal_radio_and_checkboxes,
            # radio_buttons: :horizontal_radio_and_checkboxes,
    file: :vertical_file_input,
    file_hack: :vertical_file_input,
    boolean: :vertical_boolean
  }

  config.wrappers :vertical_file_input, tag: 'fieldset', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'

    b.wrapper tag: 'div' do |ba|
      ba.use :input, class: 'form-control-file'
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :hint,  wrap_with: { tag: 'div', class: 'text-muted' }
    end
  end

  config.wrappers :vertical_boolean, tag: 'div', class: 'checkbox', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder

    b.use :label_input, boolean_style: :nested

    b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
    b.use :hint,  wrap_with: { tag: 'div', class: 'text-muted' }
  end

  config.wrappers :vertical_radio_and_checkboxes, tag: 'fieldset', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label_input
    b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
    b.use :hint,  wrap_with: { tag: 'div', class: 'text-muted' }
  end

  # Wrappers for forms and inputs using the Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :vertical_form
  SimpleForm.boolean_style = :nested
end
