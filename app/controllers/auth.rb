# frozen_string_literal: true

require 'roda'
require_relative './app'

module Coinbase
  # Web controller for Coinbase App
  class App < Roda
    plugin :flash
    route('auth') do |routing|
      routing.public
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          account_info = AuthenticateAccount.new(App.config).call(
            email: routing.params['email'],
            password: routing.params['password']
          )

          current_account = Account.new(
            account_info[:account],
            account_info[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome back #{current_account.email}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash.now[:error] = 'Email and password did not match our records'
          response.status = 400
          view :login
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      @logout_route = '/auth/logout'
      routing.on 'logout' do
        routing.get do
          CurrentSession.new(session).delete
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.public
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          routing.post do
            account_data = JsonRequestBody.symbolize(routing.params)
            VerifyRegistration.new(App.config).call(account_data)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue VerifyRegistration::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Our servers are not responding -- please try later'
            routing.redirect @register_route
          rescue StandardError => e
            App.logger.error "Could not verify registration: #{e.inspect}"
            flash[:error] = 'Registration details are not valid'
            routing.redirect @register_route
          end
        end

        routing.get(String) do |registration_token|
          flash.now[:notice] = 'Email Verified! Please fill in the remaining fields'
          new_account = SecureMessage.decrypt(registration_token)
          view :register_confirm,
               locals: { new_account:,
                         registration_token: }
        end
      end
    end
  end
end
