module LiveChat
  module REST
    class Threads
      include LiveChat::Util

      def initialize(path, client)
        @path, @client = path, client
      end

      def list(chat_id=nil)
        path = endpoint_path('agent', 'list_threads')
        url = URI.parse(path)
        body = {}
        body.merge!({chat_id: chat_id}) if chat_id.present?
        response = @client.request(url, body)
        JSON.parse(response.body)
      end

    end
  end
end