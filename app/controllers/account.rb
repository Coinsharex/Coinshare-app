# frozen_string_literal: true

require 'roda'
require_relative './app'

module Coinbase
  # Web controller for Coinbase App
  class App < Roda
    plugin :flash
    route('account') do |routing|
      routing.on do
        routing.public
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
          passwords = Form::Passwords.new.call(routing.params)

          raise Form.message_values(passwords) if passwords.failure?

          form_data = Form::RegistrationConfirm.new.call(
            routing.params
          )

          raise Form.message_values(form_data) if form_data.failure?

          new_account = SecureMessage.decrypt(registration_token)
          data = {
            first_name: new_account['first_name'],
            last_name: new_account['last_name'],
            email: new_account['email'],
            password: passwords['password'],
            occupation: form_data['occupation'],
            university: form_data['university'],
            field_of_study: form_data['field_of_study'],
            study_level: form_data['study_level'],
            picture: form_data['picture'],
            contact_number: form_data['contact_number'],
            address: form_data['address'],
            bank_name: form_data['bank_name'],
            bank_account: form_data['bank_account']
          }
          CreateAccount.new(App.config).call(data:)

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
