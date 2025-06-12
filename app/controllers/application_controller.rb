class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: t('.failure') }
    end
  end
end
