# frozen_string_literal: true

require 'roda'

module Coinbase
  # Web controller for Coinbase API
  class App < Roda
    plugin :flash
    route('requests') do |routing|
      routing.public
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @requests_route = '/requests'

        routing.on('categories') do
          routing.on(String) do |category|
            # GET /requests/categories/{category}
            routing.get do
              req_by_category = GetRequestsByCategory.new(App.config).call(
                current_account: @current_account, category:
              )

              @requests = Requests.new(req_by_category)

              view :requests_all,
                   locals: { current_user: @current_account, requests: @requests }
            end
          end
        end

        routing.on('new') do
          routing.is do
            # GET /requests/new
            routing.get do
              view :new_request
            end
          end
        end

        routing.on(String) do |request_id|
          routing.is do
            @request_route = "#{@requests_route}/#{request_id}"

            # GET /requests/[ID]
            routing.get do
              req_info = GetRequest.new(App.config).call(
                current_account: @current_account, request_id:
              )

              request = Request.new(req_info)

              view :request, locals: {
                current_account: @current_account, request:
              }
            rescue StandardError => e
              puts "#{e.inspect}\n#{e.backtrace}"
              flash[:error] = 'Request not found'
              routing.redirect @requests_route
            end

            # POST /requests/[req_id]/donations/
            # TO BE DONE LATER
            routing.post('donations') do
              # 1) Determine what kind of data that needs to be in the donation
              #  donation_data = Form::NewDonation.new.call(routing.params)
              #  if donation_data.failure?
              #    flash[:error] = Form.message_values(donation_data)
              #    routing.halt
              #  end

              # CreateNewDonation.new(App.config).call(
              #  current_account: @current_account,
              #  request_id:
              #  donation_data : donation_data.to_h
              # )

              # flash[:notice] = 'Your donation was successfully added'
              # rescue StandardError => error
              # puts error.inspect
              # puts error.backtrace
              # flash[:error] = 'Could not add donatoon'
              # ensure
              # routing.redirect @request_route
            end
          end
        end
        # GET /requests/
        routing.get do
          requests_list = GetAllRequests.new(App.config).call(@current_account)

          @requests = Requests.new(requests_list)

          view :requests_all,
               locals: { current_user: @current_account, requests: @requests }
        end

        # POST /requests/
        routing.post do
          routing.redirect 'auth/login' unless @current_account.logged_in?

          request_data = Form::NewRequest.new.call(routing.params)

          if request_data.failure?
            flash[:error] = Form.message_values(request_data)
            routing.halt
          end

          CreateNewRequest.new(App.config).call(
            current_account: @current_account,
            request_data: request_data.to_h
          )

          flash[:notice] = 'New Request successfully added'
        rescue CreateNewRequest::MonthlyRequestAllowanceError
          flash[:error] = 'You already posted 2 requests this month'
          response.status = 401
        rescue CreateNewRequest::YearlyFundsAllownaceError
          flash[:error] = 'You have asked more funds than the allowed threshold for the year'
          response.status = 403
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
        rescue StandardError => e
          puts "FAILURE Creating Request: #{e.inspect}"
          flash[:error] = 'You are not allowed to add more requests'
        ensure
          routing.redirect @requests_route
        end
      end
    end
  end
end
