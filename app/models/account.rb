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
      @account_info ? @account_info['occupation'] : nil
    end

    def university
      @account_info ? @account_info['university'] : nil
    end

    def field_of_study
      @account_info ? @account_info['field_of_study'] : nil
    end

    def study_level
      @account_info ? @account_info['study_level'] : nil
    end

    def picture
      @account_info ? @account_info['picture'] : nil
    end

    def logged_out?
      @account_info.nil?
    end

    def logged_in?
      !logged_out?
    end
  end
end
