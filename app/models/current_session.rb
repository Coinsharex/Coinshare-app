# frozen_string_literal: true

require_relative './account'

module Coinbase
  # Managing session information
  class CurrentSession
    def initialize(session)
      @secure_session = SecureSession.new(session)
    end

    def current_account
      Account.new(@secure_session.get(:account),
                  @secure_session.get(:auth_token))
    end

    def current_account=(current_account)
      @secure_session.set(:account, current_account.account_info)
      @secure_session.set(:auth_token, current_account.auth_token)
    end

    def donation_data=(data)
      @secure_session.set(:stripe_session, data[:sesh])
      @secure_session.set(:request_id, data[:request_id])
      @secure_session.set(:checkout_data, data[:checkout_data])
    end

    def donation_data
      DonationData.new(@secure_session.get(:stripe_session),
                       @secure_session.get(:request_id),
                       @secure_session.get(:checkout_data))
    end

    def delete_donation
      @secure_session.delete(:stripe_session)
      @secure_session.delete(:request_id)
      @secure_session.delete(:checkout_data)
    end

    def delete
      @secure_session.delete(:account)
      @secure_session.delete(:auth_token)
    end
  end
end
