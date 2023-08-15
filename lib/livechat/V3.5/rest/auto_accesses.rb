module LiveChat
  module REST
    class AutoAccesses
      include LiveChat::Util

      def initialize(path, client)
        @path, @client = path, client
      end

      def list
        path = endpoint_path('configuration', 'list_auto_accesses')
        url = URI.parse(path)
        body = {}
        # body.merge!({page_id: page_id}) if page_id.present?
        response = @client.request(url, body)
        JSON.parse(response.body)
      end

      def toggle_chat_on_off(auto_access_id, group_ids=nil)
        path = endpoint_path('configuration', 'update_auto_access')
        url = URI.parse(path)
        group_ids ||= -1
        Array(group_ids).flatten! # allows api to pass Array or Integer
        body = {
            "id": auto_access_id,
            "access": {
              "groups": group_ids
            }
          }
        response = @client.request(url, body)
        JSON.parse(response.body)
      end
    end
  end
end
