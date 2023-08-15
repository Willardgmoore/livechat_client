module LiveChat
  module REST
    class Chats #< ListResource
      def initialize(path, client)
        @path, @client = path, client
        #chats is different than the other resources
        # @list_key = 'chats'
      end

      def list(page_id=nil)
        path = endpoint_path('agent', 'list_chats')
        url = URI.parse(path)
        body = {}
        body.merge!({page_id: page_id}) if page_id.present?
        response = @client.request(url, body)
        JSON.parse(response.body)
      end
    end

    class Chat #< InstanceResource
      def send_transcript(*args)
        @client.post "#{@path}/send_transcript", Hash[*args]
        self
      end
    end
  end
end
