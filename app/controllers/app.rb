# frozen_string_literal: true

require 'roda'
require 'slim'

module Coinbase
  # Base class for Coinbase Web Application
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route
    plugin :flash
    plugin :assets, path: 'app/presentation/assets',
                    css: { animate: 'animate.min.css',
                           aos: 'aos.css',
                           boot: 'bootstrap.min.css',
                           carousel: 'owl.carousel.min.css',
                           carousel1: 'owl.theme.default.min.css',
                           date: 'bootstrap-datepicker.css',
                           default: 'style.css',
                           iconmoon: 'style.css',
                           jquery: 'jquery.fancybox.min.css',
                           login: 'style.css' },
                    js: { animate: 'jquery.animateNumber.min.js',
                          aos: 'aos.js',
                          bootstrap: 'bootstrap.min.js',
                          easing: 'jquery.easing.1.3.js',
                          fancy: 'jquery.fancybox.min.js',
                          jquery: 'jquery-3.3.1.min.js',
                          main: 'main.js',
                          owl: 'owl.carousel.min.js',
                          popper: 'popper.min.js',
                          sticky: 'jquery.sticky.js',
                          waypoints: 'jquery.waypoints.min.js' }

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      @current_account = CurrentSession.new(session).current_account

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        # view 'home', locals: { current_account: @current_account }
      end
    end
  end
end
