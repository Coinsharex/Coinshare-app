# frozen_string_literal: true

require 'roda'

module Coinbase
  # Web controller for Coinbase API
  class App < Roda
    plugin :flash
    route('requests') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @requests_route = '/requests'

        routing.on(String) do |request_id|
          @request_route = "#{@requests_route}/#{request_id}"

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

          # POST /projects/[proj_id]/donations/
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
        # GET /requests/
        routing.get do
          requests_list = GetAllRequests.new(App.config).call(@current_account)

          @requests = Requests.new(requests_list)

          view :requests_all,
               locals: { current_user: @current_account, requests: }
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
        rescue StandardError => e
          puts "FAILURE Creating Request: #{e.inspect}"
          flash[:error] = 'Could not create request'
        ensure
          routing.redirect @requests_route
        end
      end
    end
  end
end
