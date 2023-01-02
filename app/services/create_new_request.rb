# frozen_string_literal: true

require 'http'

module Coinbase
  # Create a new request
  class CreateNewRequest
    class MonthlyRequestAllowanceError < StandardError; end

    class YearlyFundsAllownaceError < StandardError; end

    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, request_data:)
      photo = Object::File.read(request_data[:picture][:tempfile])
      photo_encoded = Base64.strict_encode64(photo)

      config_url = "#{api_url}/requests"
      info = { 'title' => request_data[:title],
               'description' => request_data[:description],
               'location' => request_data[:location],
               'category' => request_data[:category],
               'amount' => request_data[:amount],
               'picture' => photo_encoded }
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: info)

      raise(MonthlyRequestAllowanceError) if response.code == 401
      raise(YearlyFundsAllownaceError) if response.code == 403
      raise(ApiServerError) if response.code != 201

      JSON.parse(response.body.to_s)
    end
  end
end
