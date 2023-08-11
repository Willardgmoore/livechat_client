module LiveChat
  module REST
    class Client
      include LiveChat::Util
      include LiveChat::REST::Utils

      HTTP_HEADERS = {
        'Accept' => '*/*',
        'Accept-Charset' => 'utf-8',
        'Content-Type' => 'application/json',
        'User-Agent' => "livechat-ruby/#{LiveChat::VERSION}",
        'X-API-Version' => $API_VERSION
      }

      DEFAULTS = {
        :host => 'api.livechatinc.com',
        :port => 443,
        :use_ssl => true,
        :ssl_verify_peer => true,
        :ssl_ca_file => File.dirname(__FILE__) + '/../../../conf/cacert.pem',
        :timeout => 30,
        :proxy_addr => nil,
        :proxy_port => nil,
        :proxy_user => nil,
        :proxy_pass => nil,
        :retry_limit => 1,
      }

      attr_reader :login, :last_request, :last_response

      configuration_api_endpoints = %w(agents auto_access bots groups properties tags webhooks)
      agent_chat_api_endpoints = %w(chats threads archives events properties)

      %w(agents auto_access bots groups properties tags webhooks).each do |r|
        define_method(r.to_sym) do |*args|
          klass = LiveChat::REST.const_get restify(r.capitalize)
          n = klass.new(args[0], self)
          if args.length > 0
           n.get(args[0])
          else
           n
          end
        end
      end

      ##
      # Instantiate a new HTTP client to talk to LiveChat. The parameters
      # +login+ and +api_key+ are required and used to generate the
      # HTTP basic auth header in each request.
      #
      def initialize(options={})
        yield options if block_given?
        @config = DEFAULTS.merge! options
        @login = @config[:login].strip
        @api_key = @config[:api_key].strip
        raise ArgumentError, "Login and API key are required!" unless @login and @api_key
        set_up_connection
      end

      def inspect # :nodoc:
        "<LiveChat::REST::Client @login=#{@login}>"
      end

      ##
      # Define #get, #put, #post and #delete helper methods for sending HTTP
      # requests to LiveChat. You shouldn't need to use these methods directly,
      # but they can be useful for debugging. Each method returns a hash
      # obtained from parsing the JSON object in the response body.
      [:get, :put, :post, :delete].each do |method|
        define_method method do |path, *args|
          params ||= {}
          params = args[0] if args[0]
          # expecting we should always have the full path
          if method == :get && params.present?
            path << "?#{url_encode(params)}"
          end
          params = params.to_json if [:post, :put].include? method
          # request(path, params, method)
        end
      end

      def request(url, params, method=:post) # most endpoints are post
        # url.query = URI.encode_www_form(params) if [:get].include? method
        request_type = Net::HTTP.const_get method.capitalize
        request = request_type.new url, HTTP_HEADERS
        request.basic_auth @login, @api_key
        request.body = params.to_json

        connection = Net::HTTP.start(url.host, url.port, use_ssl: true)
        return connection.request(request)
      end

      def format_url(method, params)
        url = URI.parse(path)
        if method == :get
          url.query = URI.encode_www_form(params)
        elsif [:post, :put].include? method
          params = params.to_json
        end
      end

      private

      def valid_request?(request)
        headers = request.to_hash
        raise ArgumentError, "Login and API key are required!" if !headers.keys.include?('authorization')
        raise "Can't execute without a REST Client" unless @client
        raise "Can't execute without a path" unless request.path
      end

      ##
      # Set up and cache a Net::HTTP object to use when making requests. This is
      # a private method documented for completeness.
      def set_up_connection # :doc:
        connection_class = Net::HTTP::Proxy(
          @config[:proxy_addr],
          @config[:proxy_port],
          @config[:proxy_user],
          @config[:proxy_pass])
        @connection = connection_class.new @config[:host], @config[:port]
        set_up_ssl
        @connection.open_timeout = @config[:timeout]
        @connection.read_timeout = @config[:timeout]
        @connection
      end

      ##
      # Set up the ssl properties of the <tt>@connection</tt> Net::HTTP object.
      # This is a private method documented for completeness.
      def set_up_ssl # :doc:
        # @connection.use_ssl = @config[:use_ssl]
        # if @config[:ssl_verify_peer]
        #   @connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
        #   @connection.ca_file = @config[:ssl_ca_file]
        # else
          @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        # end
      end


      ##
      # Send an HTTP request using the cached <tt>@connection</tt> object and
      # return the JSON response body parsed into a hash. Also save the raw
      # Net::HTTP::Request and Net::HTTP::Response objects as
      # <tt>@last_request</tt> and <tt>@last_response</tt> to allow for
      # inspection later.
      def connect_and_send(request) # :doc:
        @last_request = request
        retries_left = @config[:retry_limit]
        begin
            response = @connection.request request
          @last_response = response
          if response.kind_of? Net::HTTPServerError
            raise LiveChat::REST::ServerError
          end
        rescue Exception
          raise if request.class == Net::HTTP::Post
          if retries_left > 0 then retries_left -= 1; retry else raise end
        end
        if response.body and !response.body.empty?
          object = MultiJson.load response.body
        end
        if response.kind_of? Net::HTTPClientError
          raise LiveChat::REST::RequestError.new "#{object['message']}: #{response.body}", object['code']
        end
        object
      end
    end
  end
end
