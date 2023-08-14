module LiveChat
  module REST
    class Groups

      def initialize(path, client)
        @path, @client = path, client
      end

      def list(params)
        @path ||= endpoint_path('configuration', 'list_groups')
        url = URI.parse(@path)
        params ||= {
          "fields": ["agent_priorities", "routing_status"]
        }
        # binding.pry
        response = @client.request(url, params)
        JSON.parse(response.body)
      end

      def list_groups_statuses(params={})
        @path ||= endpoint_path('configuration', 'list_groups')
        url = URI.parse(@path)
        body = {
          "action": "list_group_statuses",
          "payload": {
            "all": true
          }
        }

        response = @client.request(url, params)
        JSON.parse(response.body)
      end
    end

    class Group
      def initialize(path, client)
        @path, @client = path, client
      end

      def find(params)
        @path ||= endpoint_path('configuration', 'get_group')
        url = URI.parse(@path)
        body = {
          "fields": ["agent_priorities", "routing_status"]
        }
        params = body.merge(params.transform_keys(&:to_sym))
        response = @client.request(url, params)
        JSON.parse(response.body)
      end

      def list_group_statuses(params={})
        @path ||= endpoint_path('customer', 'list_group_statuses')
        url = URI.parse(@path)
        url.query = URI.encode_www_form({organization_id: $ORGANIZATION_ID})
        body = {
            "all": true
        }
        binding.pry
        response = @client.request(url, body)
        JSON.parse(response.body)
      end
    end
  end
end
