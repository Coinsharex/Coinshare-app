# frozen_string_literal: true

require_relative 'form_base'

module Coinbase
  module Form
    # Checks when making a new donation
    class NewDonation < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_donation_error.yml')

      params do
        required(:price).filled
        optional(:comment).value(:string)
        optional(:anonymous).value(:string)
      end

      rule(:comment) do
        if key? && (value.length < 10 && value.length > 300)
          key.failure('Your comment should be between 10 and 300 characters long')
        end
      end
    end
  end
end
