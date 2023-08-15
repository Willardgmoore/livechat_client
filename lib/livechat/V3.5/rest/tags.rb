module LiveChat
  module REST
    class Tags

      def initialize(path, client)
        @path, @client = path, client
      end

      def list(group_ids)
        path ||= endpoint_path('configuration', 'list_tags')
        url = URI.parse(path)
        params = {
          "filters": {
            "group_ids":
              group_ids
          }
        }
        response = @client.request(url, params)
        JSON.parse(response.body)
      end

      def tag_thread(chat_id, thread_id, tag_name='spam')
        path = endpoint_path('agent', 'tag_thread')
        url = URI.parse(path)

        body = {
          "chat_id": chat_id,
          "thread_id": thread_id,
          "tag": tag_name
        }

        response = @client.request(url, body, :post)
        JSON.parse(response.body)
      end

      def untag_thread(chat_id, thread_id, tag_name='spam')
        path = endpoint_path('agent', 'untag_thread')
        url = URI.parse(path)

        body = {
          "chat_id": chat_id,
          "thread_id": thread_id,
          "tag": tag_name
        }

        response = @client.request(url, body, :post)
        JSON.parse(response.body)
      end
    end
  end
end