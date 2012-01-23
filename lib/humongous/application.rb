module Humongous
  class Application < Sinatra::Base
    DEFAULT_OPTIONS = {
      url: "localhost",
      port: "27017",
      username: "",
      password: ""
    }
    
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"

    if respond_to? :public_folder
      set :public_folder, "#{dir}/public"
    else
      set :public, "#{dir}/public"
    end

    set :static, true

    before do
      @connection = Mongo::Connection.from_uri(get_uri)
    end

    error Mongo::ConnectionFailure do
      [502, headers, "Humongous is unable to find MongoDB instance. Check your MongoDB connection."]
    end

    helpers do

      def get_uri(params = {})
        @options = DEFAULT_OPTIONS
        @options = @options.merge(params)
        unless @options[:username].empty? && @options[:password].empty?
          "mongodb://#{@options[:username]}:#{@options[:password]}@#{@options[:url]}:#{@options[:port]}"
        else
          "mongodb://#{@options[:url]}:#{@options[:port]}"
        end
      end
      
      def default_opts
        { skip: 0, limit: 10 }
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
          # else
          #   b[v]
          end
        end
        doc
      end
      
      def from_bson( options )
        ids = options.each_pair.select{|k,v| v.is_a? BSON::ObjectId}
        ids.each do |id|
          options[id[0]] = id[1].to_s
        end
        options
      end

      def default_opts
        { skip: 0, limit: 10 }
      end

    end

    get '/' do
      @databases = @connection.database_info
      @server_info = @connection.server_info
      @header_string = "Server #{@connection.host}:#{@connection.port} stats"
      erb :index
    end

    get "/database/:db_name" do
      @database = @connection.db(params[:db_name])
      @header_string = "Database #{@database.name} (#{@database.collection_names.size}) stats"
      content_type :json
      { collections: @database.collection_names, stats: @database.stats, header: @header_string }.to_json
    end

    get "/database/:db_name/collection/:collection_name" do
      @database = @connection.db(params[:db_name])
      @collection = @database.collection(params[:collection_name])
      content_type :json
      { stats: @collection.stats, header: "Collection #{@database.name}.#{@collection.name} (#{@collection.stats.count}) stats" }.to_json
    end

    delete "/database/:db_name/collection/:collection_name" do
      @database = @connection.db(params[:db_name])
      if @database.drop_collection(params[:collection_name])
        content_type :json
        { status: "OK", dropped: true }.to_json
      end
    end

    post "/database/:db_name/collection/:collection_name/page/:page" do
      selector = {}
      opts = {}
      query = Crack::JSON.parse(params[:query])
      query["_id"] = BSON::ObjectId.from_string(query["_id"]) if query && !!query["_id"]
      selector = selector.merge(query) if !!query
      opts[:fields] = params[:fields].split(",").collect(&:strip) unless params[:fields].empty?
      opts[:skip] = params[:skip].to_i
      opts[:sort] = Crack::JSON.parse(params[:sort])
      opts[:limit] = params[:limit].to_i
      opts = default_opts.merge(opts)
      @database = @connection.db(params[:db_name])
      @collection = @database.collection(params[:collection_name])
      @records = @collection.find(selector,opts).to_a
      @records = @records.collect{|record| doc_to_bson(record, :from_bson) }
      content_type :json
      @records.to_json
    end

    post "/database/:db_name/collection/:collection_name/save" do
      @database = @connection.db(params[:db_name])
      @collection = @database.collection(params[:collection_name])
      doc = params[:doc]
      doc = doc_to_bson(doc, :to_bson)
      # doc["_id"] = BSON::ObjectId.from_string(doc["_id"])
      @collection.save(doc)
      content_type :json
      { status: "OK", saved: true }.to_json
    end

    delete "/database/:db_name" do
      content_type :json
      @connection.drop_database(params[:db_name]).to_json
    end

    post "/database" do
      @connection.db(params["database_name"]).create_collection("test");
      { status: "OK", created: true, name: params["database_name"] }.to_json
    end

    post "/database/:database_name/collection" do
      @connection.db(params["database_name"]).create_collection(params[:collection_name]);
      { status: "OK", created: true, name: params["collection_name"] }.to_json
    end

  end

end