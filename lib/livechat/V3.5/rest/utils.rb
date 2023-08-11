module LiveChat
  module REST
    module Utils

      def restify(something)
        if something.is_a? Hash
          Hash[*something.to_a.map {|a| [restify(a[0]).to_sym, a[1]]}.flatten]
        else
          something.to_s.split('_').map do |s|
            [s[0,1].capitalize, s[1..-1]].join
          end.join
        end
      end

      def unrestify(something)
        if something.is_a? Hash
          Hash[*something.to_a.map {|pair| [unrestify(pair[0]).to_sym, pair[1]]}.flatten]
        else
          something.to_s.gsub(/[A-Z][a-z]*/) {|s| "_#{s.downcase}"}.gsub(/^_/, '')
        end
      end

      def route_mapper(something)
        puts "#{something} << mapper"
        case restify(something.capitalize)
        when 'Agents'
          "https://api.livechatinc.com/v3.5/configuration/action/" + something
        when 'Groups'
          "https://api.livechatinc.com/v3.5/configuration/action/"
        else
          something
        end
      end

    end
  end
end
