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
    end
  end
end