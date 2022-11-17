# frozen_string_literal: true

require_relative 'form_base'

module Coinbase
  # Checks for any empty spaces in
  #   module Types
  #     include Dry::Types.module

  #     Name = Types::String.constructor do |str|
  #       str ? str.strip.chomp : str
  #     end
  #   end

  module Form
    # Rules for adding a new request
    class NewRequest < Dry::Validation::Contract
      # config.messages.load_paths << File.join(__dir__, 'errors/new_request.yml')

      params do
        required(:title).filled(min_size?: 20, max_size?: 255)
        required(:description).filled(min_size?: 200, max_size?: 1440)
        required(:amount).filled
        required(:location).filled
        required(:category).filled
        required(:picture).filled
      end

      rule(:title) do
        if value.length < 20 && value.length > 255
          key.failure('provide title with at least 20 characters and up to 225 characters')
        end
      end

      rule(:description) do
        if value.length < 200 && value.length > 1440
          key.failure('provide description with at least 200 characters and up to 1440 characters')
        end
      end

      rule(:picture) do
        key.failure('Only supports images') unless value[:type] == 'image/jpeg'
        key.failure('Image file size is too big') unless value[:tempfile].size / 1024 < 1_000 # LESS THAN: 1MB
      end

      rule(:amount) do
        key.failure('The entered value should be between 5$ and 5000$') unless value.to_i >= 5 && value.to_i <= 5000
      end

      rule(:category) do
        key.failure('Please chose a valid category') if value == ''
      end

      rule(:location) do
        key.failure('Please enter a valid location') if value.length < 3
      end
    end
  end
end
