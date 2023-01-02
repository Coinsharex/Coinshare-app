# frozen_string_literal: true

require_relative 'account'

module Coinbase
  # Models a donation
  class Donation
    attr_reader :id, :amount, :identifier, :comment, :anonymous, :created_at,  # basic info
                :donor

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @amount = attributes['amount']
      @identifier = attributes['identifier']
      @comment = attributes['comment']
      @anonymous = attributes['anonymous']
      @created_at = attributes['created_at']
    end

    def process_included(included)
      @donor = Account.new(included['donor'])
    end
  end
end
