class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_invalid_record

  def render_not_found(exception)
    render json: {error: exception.message}, status: :not_found
  end

  def render_invalid_record(exception)
    render json: {error: exception.message}, status: :not_found
  end
end
