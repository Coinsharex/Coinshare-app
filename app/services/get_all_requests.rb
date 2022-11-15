# frozen_string_literal: true

require 'http'

# Returns all projects belonging to an account
class GetAllRequests
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{api_url}/requests")

    response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
  end
end
