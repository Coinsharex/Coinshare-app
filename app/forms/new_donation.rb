# frozen_string_literal: true

require_relative 'form_base'

module Coinbase
  module Form
    # Checks when making a new donation
    class NewDonation < Dry::Validation::Contract
      # config.messages.load_paths << File.join(__dir__, 'errors_new_donation.yml')

      params do
        # Check Amount field and make sure that it is filled with a number and the amount entered is between a threshold specidied by the owner of this application.
      end
    end
  end
end
