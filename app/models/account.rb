# frozen_string_literal: true

module Coinbase
  # Behaviors of the currently logged in account
  class Account
    def initialize(account_info, auth_token = nil)
      @account_info = account_info
      @auth_token = auth_token
    end

    attr_reader :account_info, :auth_token

    def first_name
      @account_info ? @account_info['attributes']['first_name'] : nil
    end

    def last_name
      @account_info ? @account_info['attributes']['last_name'] : nil
    end

    def email
      @account_info ? @account_info['attributes']['email'] : nil
    end

    def occupation
      @account_info ? @account_info['attributes']['occupation'] : nil
    end

    def university
      @account_info ? @account_info['attributes']['university'] : nil
    end

    def field_of_study
      @account_info ? @account_info['attributes']['field_of_study'] : nil
    end

    def study_level
      @account_info ? @account_info['attributes']['study_level'] : nil
    end

    def picture
      @account_info ? @account_info['attributes']['picture'] : nil
    end

    def address
      @account_info ? @account_info['attributes']['address'] : nil
    end

    def contact_number
      @account_info ? @account_info['attributes']['contact_number'] : nil
    end

    def bank_name
      @account_info ? @account_info['attributes']['bank_name'] : nil
    end

    def bank_account
      @account_info ? @account_info['attributes']['bank_account'] : nil
    end

    def logged_out?
      @account_info.nil?
    end

    def logged_in?
      !logged_out?
    end
  end
end
