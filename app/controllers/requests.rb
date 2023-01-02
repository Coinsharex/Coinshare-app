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

        routing.on('my-requests') do
          # GET /requests/my-requests
          routing.get do
            my_requests = GetMyRequests.new(App.config).call(@current_account)

            @requests = Requests.new(my_requests)

            view :requests_all,
                 locals: { current_user: @current_account, requests: @requests }
          end
        end

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
              if @current_account.bank_account.empty? || @current_account.bank_name.empty?
                view :complete_account, locals: { current_account: @current_account }
              else
                view :new_request
              end
            end
          end
        end

        routing.on(String) do |request_id|
          # routing.is do
          @request_route = "#{@requests_route}/#{request_id}"

          routing.on('destroy') do
            routing.post do
              DeleteRequest.new(App.config).call(
                current_account: @current_account,
                request_id:
              )
            end
            flash[:notice] = 'Request successfully updated'
            routing.redirect @requests_route.to_s
          rescue DeleteRequest::NotAllowedError
            flash[:error] = 'Cannot delete request that already received donations'
            response.status = 401
            routing.redirect @request_route
          rescue DeleteRequest::ApiServerError
            flash[:error] = 'Our servers are not responding -- please try later'
            response.status = 500
            routing.redirect @request_route
          ensure
            routing.redirect @requests_route.to_s
          end

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

          # Update existing Request
          # POST /requests/[ID] -> new data
          routing.post do
            updated_request_data = Form::EditRequest.new.call(routing.params)

            if updated_request_data.failure?
              flash[:error] = Form.message_values(updated_request_data)
              routing.halt
            end

            UpdateRequest.new(App.config).call(
              current_account: @current_account,
              request_id:,
              updated_request_data: updated_request_data.to_h
            )

            flash[:notice] = 'Request successfully updated'
          rescue UpdateRequest::YearlyFundsAllownaceError
            flash[:error] = 'You have asked more funds than the allowed threshold for the year'
            response.status = 403
          rescue UpdateRequest::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Our servers are not responding -- please try later'
            response.status = 500
          rescue StandardError => e
            puts "FAILURE Creating Request: #{e.inspect}"
            flash[:error] = 'You are not allowed to update more requests'
          ensure
            # routing.redirect @requests_route
            routing.redirect "#{@requests_route}/#{request_id}"
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
        rescue CreateNewRequest::ApiServerError => e
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
