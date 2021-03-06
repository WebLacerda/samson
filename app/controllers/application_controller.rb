# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  force_ssl if: :force_ssl?

  include CurrentUser # must be after protect_from_forgery, so that authenticate! is called

  protected

  def force_ssl?
    ENV['FORCE_SSL'] == '1'
  end

  def verified_request?
    warden.winning_strategy || super
  end

  # Get parameters for lograge
  def append_info_to_payload(payload)
    super
    payload["params"] = request.params
  end

  def redirect_back_or(fallback)
    if param_location = params[:redirect_to].to_s.presence
      if param_location.is_a?(String) && param_location.start_with?('/')
        redirect_to URI("http://nope.nope#{param_location}").request_uri # using URI to silence Brakeman
      else
        render status: :bad_request, plain: 'Invalid redirect_to parameter'
      end
    else
      redirect_back fallback_location: fallback
    end
  end
end
