module Humongous
  class Application < Sinatra::Base
    DEFAULT_OPTIONS = {
      url: "localhost",
      port: "27017",
      username: "",
      password: ""
    }

    set :port, 9494

    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"

    if respond_to? :public_folder
      set :public_folder, "#{dir}/public"
    else
      set :public, "#{dir}/public"
    end

    set :static, true

    before do
      begin
        @connection = Mongo::Connection.from_uri(get_uri)
      rescue Mongo::ConnectionFailure => e
        @is_live = false
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

    post "/database/:db_name/collection/:collection_name/page/:page" do
      default_options = { skip: 0, limit: 10 }
      default_query_options = {}
      optionss = {}
      query = Crack::JSON.parse(params[:query])
      query_options = default_query_options.merge(query) if !!query
      optionss[:fields] = params[:fields].split(",").collect(&:strip) unless params[:fields].empty?
      optionss[:skip] = params[:skip].to_i
      optionss[:sort] = Crack::JSON.parse(params[:sort])
      optionss[:limit] = params[:limit].to_i
      optionss = default_options.merge(optionss)
      @database = @connection.db(params[:db_name])
      @collection = @database.collection(params[:collection_name])
      @records = @collection.find(query_options,optionss).to_a
      @records.each do |record|
        record["_id"] = record["_id"].to_s
      end
      content_type :json
      @records.to_json
    end
    
    get "/connection_failed" do
      "<h1>Your Mongo Instance does not seems to be running</h1>"
    end
    
    post "/database/:db_name/collection/:collection_name/save" do
      @database = @connection.db(params[:db_name])
      @collection = @database.collection(params[:collection_name])
      doc = params[:doc]
      doc["_id"] = BSON::ObjectId.from_string(doc["_id"])
      @collection.save(params[:doc])
      { status: "OK", saved: true }.to_json
    end
    
    private
    
    def load_defaults
      
    end
    
    def get_uri(params = {})
      @options = DEFAULT_OPTIONS
      @options = @options.merge(params)
      unless @options[:username].empty? && @options[:password].empty?
        "mongodb://#{@options[:username]}:#{@options[:password]}@#{@options[:url]}:#{@options[:port]}"
      else
        "mongodb://#{@options[:url]}:#{@options[:port]}"
      end
    end
  end
end