module ACube
  module Endpoint
    class Auth < CommonBase
      def login
        response = connection.post do |req|
          req.url "/login"
          req.body = {
            email: ACube.username,
            password: ACube.password
          }.to_json
        end

        if response.success?
          token = JSON.parse(response.body).token
          Rails.cache.write(ACube.auth_token_cache_key, token, expires_in: 20.hours)
          return token
        else
          raise "Login failed"
        end
      end

      def logout
        Rails.cache.delete(ACube.auth_token_cache_key)
      end

      def token!
        Rails.cache.fetch(ACube.auth_token_cache_key) do
          login
        end
      end
    end
  end
end