# frozen_string_literal: true

require_relative 'donation'

module Coinbase
  # List of all donations of a given user
  class Donations
    attr_reader :all

    def initialize(donations_list)
      @all = donations_list.map do |donation|
        Donation.new(donation)
      end
    end
  end
end
