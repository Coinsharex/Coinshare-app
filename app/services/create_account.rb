# frozen_string_literal: true

require 'http'

module Coinbase
  # Returns an authenticated user, or nil
  class CreateAccount
    # Error for accounts that cannot be created
    class InvalidAccount < StandardError
      def message = 'This account can no longer be created: please start again'
    end

    def initialize(config)
      @config = config
    end

    def call(data:)
      message = { first_name: data[:first_name],
                  last_name: data[:last_name],
                  email: data[:email],
                  password: data[:password],
                  occupation: data[:occupation],
                  university: data[:university],
                  field_of_study: data[:field_of_study],
                  study_level: data[:study_level],
                  picture: data[:picture],
                  contact_number: data[:contact_number],
                  address: data[:address],
                  bank_name: data[:bank_name],
                  bank_account: data[:bank_account] }

      response = HTTP.post(
        "#{@config.API_URL}/accounts/",
        json: message
      )

      raise InvalidAccount unless response.code == 201
    end
  end
end
