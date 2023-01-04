# frozen_string_literal

require 'roda'
require_relative './app'

module Coinbase
  # Web Controller for Coinbase
  class App < Roda
    route('privacy_terms') do |routing|
      routing.public

      # GET /privacy_terms
      routing.get do
        view :privacy_terms
      end
    end
  end
end
