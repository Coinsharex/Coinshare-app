# frozen_string_literal: true

require_relative 'account'

module Coinbase
  # Models a donation
  class Summary
    attr_reader :count, :amount # basic info

    # :request
    def initialize(info)
      process_attributes(info['attributes'])
      # process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      return unless attributes

      @count = attributes['count']
      @amount = attributes['amount']
    end

    # def process_included(included)
    #   @request = Request.new(included['request'])
    # end
  end
end
