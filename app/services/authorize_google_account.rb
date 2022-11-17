# frozen_string_literal: true

require 'http'

module Coinbase
  # Returns an authenticated user or nil
  class AuthorizeGoogleAccount
    # Errors emanating from Google
    class UnauthorizedError < StandardError
      def message
        'Could not login with Google'
      end
    end

    def initialize(config)
      @config = config
    end

    def call(code)
      id_token = get_id_token_from_google(code)
      get_sso_account_from_api(id_token)
    end

    private

    def get_id_token_from_google(code)
      challenge_response =
        HTTP.headers(accept: 'application/json')
            .post(@config.GOOGLE_TOKEN_URL,
                  form: { client_id: @config.GOOGLE_CLIENT_ID,
                          client_secret: @config.GOOGLE_CLIENT_SECRET,
                          redirect_uri: @config.REDIRECT_URI.to_s,
                          grant_type: 'authorization_code',
                          code: })
      raise UnauthorizedError unless challenge_response.status < 400

      JSON.parse(challenge_response)['id_token']
    end

    def get_sso_account_from_api(id_token)
      response =
        HTTP.post("#{@config.API_URL}/auth/sso",
                  json: { id_token: })
      raise if response.code >= 400

      account_info = JSON.parse(response)['data']['attributes']

      {
        account: account_info['account'],
        auth_token: account_info['auth_token']
      }
    end
  end
end
