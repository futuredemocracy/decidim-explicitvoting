# frozen_string_literal: true

module Decidim
  module Verifications
    module Sms
      class ExampleGateway
        # attr_reader :mobile_phone_number, :code, :context
        #
        # def initialize(mobile_phone_number, code, context = {})
        #   @mobile_phone_number = mobile_phone_number
        #   @code = code
        #   @context = context
        # end
        #
        # def deliver_code
        #   Rails.logger.debug { "Example SMS gateway service, verification code is: #{code}, should have been delivered to #{mobile_phone_number}" }
        #   true
        # end
        attr_reader :mobile_phone_number, :code, :context

        def initialize(mobile_phone_number, code, context = {})
          @mobile_phone_number = normalize_number(mobile_phone_number)
          @code = code
          @context = context
        end

        def deliver_code
          uri = URI.parse("https://api.smsapi.pl/sms.do")

          request = Net::HTTP::Post.new(uri)
          request["Authorization"] = "Bearer #{Rails.application.credentials.dig(:smsapi, :token)}"
          request.set_form_data(
            "to" => mobile_phone_number,
            "message" => text
            # "from" => Rails.application.credentials.dig(:smsapi, :from) || "Info"
            # "from" => "Info"
          )

          req_options = {
            use_ssl: uri.scheme == "https",
          }

          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end

          binding.pry
          response.is_a?(Net::HTTPSuccess)
        rescue => e
          Rails.logger.error("SMSAPI Error: #{e.message}")
          false
        end

        private

        def normalize_number(number)
          number.gsub(/\s+/, "")
        end

        def text
          I18n.t("decidim.verifications.sms.authorizations.create.text", code: code)
        end
      end
    end
  end
end
