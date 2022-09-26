# frozen_string_literal: true

require 'roda'

module Coinbase
  # Web controller for Coinbase API
  class App < Roda
    plugin :flash
    route('requests') do |routing|
      routing.on do
        # GET /requests/
        routing.get do
          if @current_account.logged_in?
            requests_list = GetAllRequests.new(App.config).call(@current_account)

            requests = Requests.new(requests_list)

            view :requests_all,
                 locals: { current_user: @current_account, requests: }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
