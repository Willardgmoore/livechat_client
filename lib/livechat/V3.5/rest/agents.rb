module LiveChat
  module REST
    class Agents
      include LiveChat::Util

      def initialize(path, client)
        @path, @client = path, client
      end

      def list(params = {}, full_path=false)
        params ||=
          {
            "fields": [
              "email_subscriptions",
              "max_chats_count",
              "job_title"
            ],
            "filters": {
              "group_ids": [
                0,
                1
              ]
            }
          }.to_json
        @path ||= endpoint_path('configuration', 'list_agents')
        url = URI.parse(@path)

        response = @client.request(url, params)
        JSON.parse(response.body)
      end

    end

    class Agent < InstanceResource
      def reset_api_key
        raise "Can't execute without a REST Client" unless @client
        set_up_properties_from(@client.put("#{@path}/reset_api_key", {}))
        self
      end
    end
  end
end
