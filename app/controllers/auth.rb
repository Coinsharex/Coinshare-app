# frozen_string_literal: true

require 'roda'
require_relative './app'

module Coinbase
  # Web controller for Coinbase App
  class App < Roda
    plugin :flash

    def google_link
      url = App.config.GOOGLE_OAUTH_URL
      oauth_params = ["client_id=#{App.config.GOOGLE_CLIENT_ID}",
                      "redirect_uri=#{App.config.REDIRECT_URI}",
                      "scope=#{App.config.SCOPE}",
                      'response_type=code'].join('&')
      "#{url}?#{oauth_params}"
    end

    route('auth') do |routing|
      routing.public
      @oauth_callback = '/auth/oauth2callback'
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login, locals: {
            google_link:
          }
        end

        # POST /auth/login
        routing.post do
          credentials = Form::LoginCredentials.new.call(routing.params)

          if credentials.failure?
            flash[:error] = 'Please enter both email and password'
            routing.redirect @login_route
          end

          authenticated = AuthenticateAccount.new.call(**credentials.values)

          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account
          flash[:notice] = "Welcome back #{current_account.first_name} #{current_account.last_name}!"
          routing.redirect '/'
        rescue AuthenticateAccount::NotAuthenticatedError
          flash[:error] = 'Email and password did not match our records'
          response.status = 401
          routing.redirect @login_route
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      routing.is 'oauth2callback' do
        # GET /auth/oauth2callback
        routing.get do
          authorized = AuthorizeGoogleAccount
                       .new(App.config)
                       .call(routing.params['code'])

          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )
          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome #{current_account.first_name}!"
          routing.redirect '/requests'
        rescue AuthorizeGoogleAccount::UnauthorizedError
          flash[:error] = 'Could not login with Google'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
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
            registration = Form::Registration.new.call(routing.params)

            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end

            VerifyRegistration.new(App.config).call(registration)

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

        # GET /auth/register/<token>
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
