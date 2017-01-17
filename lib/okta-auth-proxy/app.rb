require 'sinatra'
require 'okta-auth-proxy/auth'

module OktaAuthProxy
  class ProxyApp < Sinatra::Base
    register OktaAuthProxy::OktaAuth

     # Block that is called back when authentication is successful
    [:get, :post, :put, :head, :delete, :options, :patch, :link, :unlink].each do |verb|

      send verb, '/*' do
        pass if request.host == (ENV['AUTH_DOMAIN'] || 'localhost')
        pass if request.path == '/auth/saml/callback'
        protected!
        # If authorized, serve request
        if url = authorized?(request.host)
          headers "X-Remote-User" => session[:email]
          # Conserve the request method
          if request.referrer and not request.referrer.include? '.okta.com'
            headers "X-Reproxy-Method" => request.request_method
          end
          headers "X-Reproxy-URL" => File.join(url, request.fullpath)
          headers "X-Accel-Redirect" => "/reproxy"
          redirect to('http://localhost')
        end
      end

      send verb, '/auth/:name/callback' do
        auth = request.env['omniauth.auth']
        session[:logged] = true
        session[:provider] = auth.provider
        session[:uid] = auth.uid
        session[:name] = auth.info.name
        session[:email] = auth.info.email
        if request.env.has_key? 'HTTP_X_FORWARDED_FOR'
          session[:remote_ip] = request.env['HTTP_X_FORWARDED_FOR']
        else
          session[:remote_ip] = request.env['HTTP_X_REAL_IP']
        end
        redirect to(params[:RelayState] || '/')
      end

      send verb, '/auth/failure' do
        'Login failed'
      end
    end
  end
end
