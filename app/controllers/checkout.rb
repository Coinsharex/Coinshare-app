# frozen_string_literal: true

require 'roda'
require 'slim'

module Coinbase
  # Web controller for Coinbase APP
  class App < Roda
    plugin :flash
    route('checkout') do |routing|
      routing.on(String) do |request_id|
        routing.redirect '/auth/login' unless @current_account.logged_in?

        routing.post do
          checkout_data = Form::NewDonation.new.call(routing.params)
          if checkout_data.failure?
            flash[:error] = Form.message_values(checkout_data)
            routing.halt
          end
          session = CreateNewCheckoutSession.new(App.config).call(
            current_account: @current_account,
            checkout_data: checkout_data.to_h
          )
          PersistDonationData.new(App.config).call(
            current_account: @current_account,
            session:,
            request_id:,
            checkout_data: checkout_data.to_h
          )
          routing.redirect session.url, 303
          # TODO: Catch the errors that can be thrown
        end
      end
    end

    route('success') do |routing|
      # GET /success
      routing.get do
        view :success
      end
    end

    route('cancel') do |routing|
      # GET /cancel
      routing.get do
        view :cancel
      end
    end
  end
end
