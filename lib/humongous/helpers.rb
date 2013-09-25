module Humongous
  module Helpers
    
    module SinatraHelpers
      
      def connection(params)
        opts = opts_to_connect(params)
        session[:connection] ||= Mongo::Connection.new(opts[:url], opts[:port])
      end

      def autanticate!
        @connection.apply_saved_authentication and return unless @connection.auths.blank?
        return if params[:auth].blank? || params[:auth].collect{|_, v| v.blank?}.all?
        @connection.add_auth(params[:auth][:db], params[:auth][:username], params[:auth][:password])
        @connection.apply_saved_authentication
      end

      def opts_to_connect(params = {})
        return @options if @options && @options[:freeze]
        @options = {
          :url => "localhost",
          :port => "27017",
          :username => "",
          :password => ""
        }
        return @options if params.blank?
        @options.merge({ :url => params[:url], :port => params[:port], :freeze => true })
      end

      def get_uri(params = {})
        @options = {
          :url => "localhost",
          :port => "27017",
          :username => "",
          :password => ""
        }
        @options = @options.merge(params)
        unless @options[:username].empty? && @options[:password].empty?
          "mongodb://#{@options[:username]}:#{@options[:password]}@#{@options[:url]}:#{@options[:port]}"
        else
          "mongodb://#{@options[:url]}:#{@options[:port]}"
        end
      end
      
      def default_opts
        { :skip => 0, :limit => 10 }
      end
      
      def to_bson( options )
        ids = options.keys.grep /_id$/
        ids.each do |id|
          begin
            options[id] = BSON::ObjectId.from_string(options[id])
          rescue BSON::InvalidObjectId
            puts "found illegal ObjectId, skipping..."
            next
          rescue e
            puts e.message
          end
        end
        options
      end
      
      def doc_to_bson( doc, converter )
        doc = send(converter, doc)
        doc.each do |k,v|
          case v
          when Hash
            send(converter, v )
          end
        end
        doc
      end
      
      def from_bson( options )
        ids = options.select{ |k,v| v.is_a? BSON::ObjectId }
        ids.each do | k, v |
          options[k] = v.to_s
        end
        options
      end
      
      def json_converter( params_json )
        params_json.gsub(/(\w+):/, '"\1":')
      end

      def logger
        request.logger
      end

      def debug(message)
        logger.info("[DEBUG] STARTS")
        logger.info("\t[DUMP][PARAMS]#{params.inspect}")
        logger.info("\t[DUMP] #{message}")
        logger.info("[DEBUG] ENDS")
      end
      alias_method :d, :debug
      
    end
    
  end
end