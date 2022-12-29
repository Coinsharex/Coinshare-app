# frozen_string_literal: true

require 'roda'
require 'slim'

module Coinbase
  # Web Controller for Coinbase API
  class App < Roda
    plugin :flash

    route('my-donations') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?
      routing.get do
        my_donations = GetMyDonations.new(App.config).call(@current_account)

        @donations = Donations.new(my_donations)

        view :my_donations,
             locals: { current_account: @current_account, donations: @donations }
      end
    end
  end
end
