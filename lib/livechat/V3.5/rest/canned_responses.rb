module LiveChat
  module REST
    class CannedResponses
      include LiveChat::Util

      def initialize(path, client)
        @path, @client = path, client
      end

      def list(params=nil)
        url = URI.parse('https://api.livechatinc.com/canned_responses')
        response = @client.request(url, params, :get)
        JSON.parse(response.body)
      end
    end

    class CannedResponse < InstanceResource
    end
  end
end
