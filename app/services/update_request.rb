# frozne_string_literal: true

require 'http'

module Coinbase
  # Update an existing request
  class UpdateRequest
    class YearlyFundsAllownaceError < StandardError; end

    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, request_id:, updated_request_data:)
      unless updated_request_data[:picture].nil?
        photo = Object::File.read(updated_request_data[:picture][:tempfile])
        photo_encoded = Base64.strict_encode64(photo)
        updated_request_data[:picture] = photo_encoded
      end
      response = HTTP.auth("Bearer #{current_account}")
                     .put("#{api_url}/requests/#{request_id}")

      raise(YearlyFundsAllownaceError) if response.code == 403
      raise(ApiServerError) if response.code != 200

      JSON.parse(response.body.to_s)
    end
  end
end
