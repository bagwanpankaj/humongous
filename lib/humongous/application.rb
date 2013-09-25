module Humongous

  MonkeyPatch.activate!

  class Application < Sinatra::Base
    DEFAULT_OPTIONS = {
      :url => "localhost",
      :port => "27017",
      :username => "",
      :password => ""
    }

    use Rack::Session::Pool, :expire_after => 2592000

    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"

    if respond_to? :public_folder
      set :public_folder, "#{dir}/public"
    else
      set :public, "#{dir}/public"
    end

    set :static, true

    before do
      puts "\n\n\n"
      p params
      puts "\n\n\n"
      @connection = connection(params)
      autanticate!
    end

    error Mongo::ConnectionFailure do
      halt 502, headers, "Humongous is unable to find MongoDB instance. Make sure that MongoDB is running."
    end

    error Mongo::OperationFailure do
      halt 401, {'Content-Type' => 'text/javascript'}, { :errmsg => "Need to login", :ok => false }.to_json
    end

    helpers { include Humongous::Helpers::SinatraHelpers }

    reciever = lambda do
      # begin
      #   @databases = @connection.database_info
      #   @server_info = @connection.server_info
      #   @header_string = "Server #{@connection.host}:#{@connection.port} stats"
      # rescue Mongo::OperationFailure => e
      #   @databases = []
      #   @server_info = { :errmsg => "Need to login", :ok => false }
      #   @header_string = "Server #{@connection.host}:#{@connection.port} stats"
      #   @force_login = true
      # end
      haml :index
    end

    # get "/", &reciever
    # post "/", &reciever
    
    get "/" do
      haml :index
    end
    
    post "/" do
      
    end

    get "/database/:db_name" do
      @database = @connection.db(params[:db_name])
      @header_string = "Database #{@database.name} (#{@database.collection_names.size}) stats"
      content_type :json
      { :collections => @database.collection_names, :stats => @database.stats, :header => @header_string }.to_json
    end

    get "/database/:db_name/collection/:collection_name" do
      @database = @connection.db(params[:db_name])
      @collection = @database.collection(params[:collection_name])
      content_type :json
      { :stats => @collection.stats, :header => "Collection #{@database.name}.#{@collection.name} (#{@collection.stats.count}) stats" }.to_json
    end

    delete "/database/:db_name/collection/:collection_name" do
      @database = @connection.db(params[:db_name])
      if @database.drop_collection(params[:collection_name])
        content_type :json
        { :status => "OK", :dropped => true }.to_json
      end
    end

    post "/database/:db_name/collection/:collection_name/page/:page" do
      selector = {}
      opts = {}
      if params[:query].present?
        query = JSON.parse(json_converter(params[:query]))
        query["_id"] = BSON::ObjectId.from_string(query["_id"]) if query["_id"].present?
        selector = selector.merge(query)
      end
      opts[:fields] = params[:fields].split(",").collect(&:strip) unless params[:fields].blank?
      opts[:skip] = params[:skip].to_i
      opts[:sort] = JSON.parse(json_converter(params[:sort])) if params[:sort].present?
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
      { :status => "OK", :saved => true }.to_json
    end

    delete "/database/:db_name" do
      content_type :json
      @connection.drop_database(params[:db_name]).to_json
    end

    post "/database" do
      @connection.db(params["database_name"]).create_collection("test");
      content_type :json
      { :status => "OK", :created => true, :name => params["database_name"] }.to_json
    end

    post "/database/:database_name/collection" do
      @connection.db(params["database_name"]).create_collection(params[:collection_name]);
      content_type :json
      { :status => "OK", :created => true, :name => params["collection_name"] }.to_json
    end

    delete "/database/:database_name/collection/:collection_name/remove" do
      selector = {}
      opts = {}
      query = JSON.parse(json_converter(params[:remove_query])) if params[:remove_query].present?
      query["_id"] = BSON::ObjectId.from_string(query["_id"]) if query.present? && query["_id"].present?
      selector = selector.merge(query) if !!query
      @database = @connection.db(params["database_name"])
      @collection = @database.collection(params["collection_name"])
      content_type :json
      { :removed => @collection.remove( selector, opts ), :status => "OK" }.to_json
    end
    
    post "/database/:database_name/collection/:collection_name/insert" do
      created = false
      @database = @connection.db(params[:database_name])
      @collection = @database.collection(params[:collection_name])
      if params[:doc].present?
        doc = JSON.parse(json_converter(params[:doc]))
        @collection.insert(doc)
        created = true
      end
      content_type :json
      { :created => created, :id => true, :status => "OK" }.to_json
    end
    
    post "/database/:database_name/collection/:collection_name/mapreduce" do
      opts = { :out => { :inline => true }, :raw => true }
      opts[:finalize] = params[:finalize] unless params[:finalize].blank?
      opts[:out] = params[:out] unless params[:out].blank?
      opts[:query] = JSON.parse(json_converter(params[:query])) unless params[:query].blank?
      opts[:sort] = params[:sort] unless params[:sort].blank?
      opts[:limit] = params[:limit] unless params[:limit].blank?
      @database = @connection.db(params[:database_name])
      @collection = @database.collection(params[:collection_name])
      content_type :json
      @collection.map_reduce( params[:map], params[:reduce], opts ).to_json
    end

  end

end