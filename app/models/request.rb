# frozen_string_literal: true

module Coinbase
  # Information regarding a single request
  class Request
    attr_reader :id, :title, :description, :location, :category, :amount, :picture, :active, :created_at, # basic info
                :requestor, :donations, :summary, :policies # full_details

    def initialize(req_info)
      process_attributes(req_info['attributes'])
      process_relationships(req_info['relationships'])
      process_policies(req_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @title = attributes['title']
      @description = attributes['description']
      @location = attributes['location']
      @category = attributes['category']
      @amount = attributes['amount']
      @picture = attributes['picture']
      @active = attributes['active']
      @created_at = attributes['created_at']
    end

    def process_relationships(relationships)
      return unless relationships

      @requestor = Account.new(relationships['requestor'])
      @summary = Summary.new(relationships['summary']) unless relationships['summary'].nil?
      @donations = process_donations(relationships['donations'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_donations(donations_info)
      return nil unless donations_info

      donations_info.map { |donation_info| Donation.new(donation_info) }
    end
  end
end
