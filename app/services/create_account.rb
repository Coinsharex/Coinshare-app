# frozen_string_literal: true

require 'http'

module Coinbase
  # Returns an authenticated user, or nil
  class CreateAccount
    class InvalidAccount < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(first_name:, last_name:, email:, password:, occupation:, university:, field_of_study:, study_level:,
             picture:)

      message = { first_name:,
                  last_name:,
                  email:,
                  password:,
                  occupation:,
                  university:,
                  field_of_study:,
                  study_level:,
                  picture: }

      response = HTTP.post(
        "#{@config.API_URL}/accounts/",
        json: message
      )

      raise InvalidAccount unless response.code == 201
    end
  end
end
