# frozen_string_literal: true

module Coinbase
  # Information regarding a single request
  class Request
    attr_reader :id, :title, :description, :location, :category, :amount, :picture, :active

    def initialize(req_info)
      @id = req_info['attributes']['id']
      @title = req_info['attributes']['title']
      @description = req_info['attributes']['description']
      @location = req_info['attributes']['location']
      @category = req_info['attributes']['category']
      @amount = req_info['attributes']['amount']
      @picture = req_info['attributes']['picture']
      @active = req_info['attributes']['active']
    end
  end
end
