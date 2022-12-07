# frozen_string_literal: true

require_relative 'form_base'

module Coinbase
  module Form
    # Checks for login fields
    class LoginCredentials < Dry::Validation::Contract
      params do
        required(:email).filled(format?: EMAIL_REGEX)
        required(:password).filled
      end
    end

    # Checks for registraton fields
    class Registration < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/account_details.yml')

      params do
        required(:first_name).filled(format?: NAME_REGEX, min_size?: 2)
        required(:last_name).filled(format?: NAME_REGEX, min_size?: 2)
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end

    # Checks for registration confirmation fields
    class RegistrationConfirm < Dry::Validation::Contract
      params do
        required(:occupation).filled
        required(:university).filled
        required(:field_of_study).filled
        required(:study_level).filled
        required(:picture).filled
      end

      rule(:occupation) do
        key.failure('Please choose an occupation') if value == ''
      end

      rule(:university) do
        key.failure('Please enter a university or N/A if you did not attend any') if value == ''
      end

      rule(:field_of_study) do
        key.failure('Please enter the field that you study or N/A') if value == ''
      end

      rule(:study_level) do
        key.failure('Please choose your highest study level') if value == ''
      end

      rule(:picture) do
        key.failure('Only supports images') unless value[:type] == 'image/png' || value[:type] == 'image/jpeg'
        key.failure('Image file size is too big') unless value[:tempfile].size / 1024 < 1_000 # LESS THAN: 1MB
      end
    end

    # Checks the password fields
    class Passwords < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/password.yml')

      params do
        required(:password).filled
        required(:password_confirm).filled
      end

      def enough_entropy?(string)
        StringSecurity.entropy(string) >= 3.0
      end

      rule(:password) do
        key.failure('Password is too simple. Please make it more complex') unless enough_entropy?(value)
      end

      rule(:password, :password_confirm) do
        key.failure('Password do not match') unless values[:password].eql?(values[:password_confirm])
      end
    end
  end
end
