# frozen_string_literal: true

require 'roda'
require_relative './app'

module Coinbase
  # Web controller for Coinbase App

  class App < Roda
    plugin :flash
    route('account_info') do |routing|
      routing.public
      routing.on('update') do
        # GET /account_info/update
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @requests_route = '/requests'

        routing.get do
          view :complete_account, locals: { current_account: @current_account }
        end

        routing.post do
          # Take info and update the existing account
          updated_data = Form::RegistrationConfirm.new.call(routing.params)
          if updated_data.failure?
            flash[:error] = Form.validation_errors(updated_data)
            routing.redirect @requests_route
          end

          data = UpdateAccount.new(App.config).call(
            current_account: @current_account,
            data: updated_data.to_h
          )

          current_account = Account.new(
            data[:account],
            @current_account.auth_token
          )
          CurrentSession.new(session).current_account = current_account

          flash[:notice] = 'Account successfully updated'
        rescue UpdateAccount::ApiServerError
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
        rescue StandardError => e
          puts "FAILURE Creating Request: #{e.inspect}"
          flash[:error] = 'An uknown error occured'
        ensure
          # routing.redirect @requests_route
          routing.redirect "#{@requests_route}/"
        end
      end
    end
  end
end
