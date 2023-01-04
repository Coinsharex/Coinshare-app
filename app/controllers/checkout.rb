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
          sesh = CreateNewCheckoutSession.new(App.config).call(
            current_account: @current_account,
            checkout_data: checkout_data.to_h
          )

          data = {
            sesh:,
            request_id:,
            checkout_data: checkout_data.to_h
          }

          CurrentSession.new(session).donation_data = data
          routing.redirect sesh.url, 303
          # routing.redirect '/success'
          # TODO: Catch the errors that can be thrown
        end
      end
    end

    route('success') do |routing|
      # GET /success
      routing.get do
        routing.public
        routing.redirect '/auth/login' unless @current_account.logged_in?
        donation_data = CurrentSession.new(session).donation_data
        PersistDonationData.new(App.config).call(
          current_account: @current_account,
          data: donation_data
        )

        # TransferFunds.new(App.config).call(
        #   current_account: @current_account,
        #   data: donation_data
        # )

        CurrentSession.new(session).delete_donation
        view :success
      end
    end

    route('cancel') do |routing|
      # GET /cancel
      routing.get do
        routing.public
        CurrentSession.new(session).delete_donation
        view :cancel
      end
    end
  end
end
