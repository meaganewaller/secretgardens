module ValidRequest
  extend ActiveSupport::Concern

  def valid_request_origin?
    return true if Rails.env.test?

    if (referer = request.referer).present?
      referer.start_with?(Url.url)
    else
      origin = request.origin
      if origin == "null"
        raise ::ActionController::InvalidAuthenticityToken, ::ApplicationController::NULL_ORIGIN_MESSAGE
      end

      origin.nil? || origin.gsub("https", "http") == request.base_url.gsub("https", "http")
    end
  end

  def _compute_redirect_to_location(request, options)
    case options
    when %r{\A([a-z][a-z\d\-+.]*:|//).*}i
      options
    when String
      "#{Url.protocol || request.protocol}#{request.host_with_port}#{options}"
    when Proc
      _compute_redirect_to_location request, instance_eval(&options)
    when Array
      url_for
    else
      url_for(options)
    end.delete("\0\r\n")
  end
end
