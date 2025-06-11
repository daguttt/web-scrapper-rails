module ApplicationHelper
  def form_errors(model, attribute)
    render 'shared/form_control_errors', model: model, attribute: attribute
  end
end
