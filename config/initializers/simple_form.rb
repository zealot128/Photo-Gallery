# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|

  inputs = %w[
    CollectionSelectInput
    DateTimeInput
    FileInput
    GroupedCollectionSelectInput
    NumericInput
    PasswordInput
    RangeInput
    StringInput
    TextInput
  ]

  config.wrappers :bootstrap, :tag => 'div', :class => 'form-group', :error_class => 'fieldWithErrors' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper tag: "div", class: "col-sm-3" do |ba|
      ba.use :label, class: "control-label"
    end
    b.wrapper tag: "div", class: "col-sm-7" do |ba|
      ba.use :input #, class: "form-control"
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'has-error alert help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
    end
  end
  config.label_class = 'control-label'

  inputs.each do |input_type|
    superclass = "SimpleForm::Inputs::#{input_type}".constantize
    new_class = Class.new(superclass) do
      def input_html_classes
        super.push('form-control')
      end
    end
    Object.const_set(input_type, new_class)
  end


  config.default_wrapper = :bootstrap

  config.boolean_style = :nested
  config.button_class = 'btn'
  #config.label_class = 'control-label'
  config.form_class = 'simple_form form-horizontal'

  config.wrappers :prepend, :tag => 'div', :class => "control-group", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'alert-error help-block' }
    end
  end

  config.wrappers :append, :tag => 'div', :class => "control-group", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-append' do |append|
        append.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'alert-error help-block' }
    end
  end

  config.wrappers :color, :tag => 'div', :class => "control-group", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-append color colorpicker', "data-color-format" => "hex" do |append|
        append.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'alert-error help-block' }
    end
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
