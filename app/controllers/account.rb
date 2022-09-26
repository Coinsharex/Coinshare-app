# frozen_string_literal: true

require 'roda'
require_relative './app'

module Coinbase
  # Web controller for Coinbase App
  class App < Roda
    plugin :flash
    route('account') do |routing|
      routing.on do
        # GET /account
        routing.get String do |email|
          if @current_account && @current_account.email == email
            view :account, locals: { current_account: @current_account }
          else
            routing.redirect '/auth/login'
          end
        end

        # POST /account/<registration_token>
        routing.post String do |registration_token|
          raise 'Passwords do not match or empty' if
            routing.params['password'].empty? ||
            routing.params['password'] != routing.params['password_confirm']

          new_account = SecureMessage.decrypt(registration_token)
          CreateAccount.new(App.config).call(
            first_name: new_account['first_name'],
            last_name: new_account['last_name'],
            email: new_account['email'],
            password: routing.params['password'],
            occupation: routing.params['occupation'],
            university: routing.params['university'],
            field_of_study: routing.params['field_of_study'],
            study_level: routing.params['study_level'],
            picture: routing.params['picture']
          )

          flash[:notice] = 'Account created! Please login'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/register'
        rescue StandardError => e
          flash[:error] = e.message
          routing.redirect(
            "#{App.config.APP_URL}/auth/register/#{registration_token}"
          )
        end
      end
    end
  end
end
