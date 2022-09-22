# frozen_string_literal: true

require_relative 'request'

module Coinbase
  # List of all requests
  class Requests
    attr_reader :all

    def initialize(requests_list)
      @all = requests_list.map do |req|
        Request.new(req)
      end
    end
  end
end
