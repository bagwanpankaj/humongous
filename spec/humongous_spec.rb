require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

describe 'Humongous::Application' do
  include Rack::Test::Methods

  def app
    Humongous::Application
  end
  
  before(:all) do
    @connection = Mongo::Connection.from_uri("mongodb://localhost:27017")
    @database = @connection.db("humongous_test")
    @collection = @database.create_collection("local")
    @collection.insert({name: "test", age: 12})
    @doc = @collection.find_one({name: "test"})
  end
  
  describe "Connection" do
    it "should get sever stats" do
      get '/'
      last_response.should be_ok
      last_response.headers["Content-Type"].should == "text/html;charset=utf-8"
    end
  end

  describe "Database" do
    
    describe "Show" do
      before(:all) do
        get '/database/humongous_test'
        @parsed_body = Crack::JSON.parse(last_response.body)
      end
    
      it "should give proper response" do
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
      end
    
      it "should contain proper key in json response" do
        @parsed_body.keys.should include("collections")
        @parsed_body.keys.should include("stats")
        @parsed_body.keys.should include("header")
      end
    
      it "should contain expected results" do
        @parsed_body["header"].should include("Database humongous_test")
        @parsed_body["stats"]["db"].should == "humongous_test"
        @parsed_body["collections"].should == @database.collection_names
      end
    end

    describe "Delete" do

      before(:all) do
        @database = @connection.db("humongous_delete_test")
        @collection = @database.create_collection("local")
        delete "/database/humongous_delete_test"
        @parsed_body = Crack::JSON.parse(last_response.body)
      end

      it "should delete database" do
        last_response.should be_ok
        @parsed_body["dropped"].should == "humongous_delete_test"
        @parsed_body["ok"].should == 1.0
      end

    end
  end
  
  describe "Collection" do
    
    describe "Collection stats" do
      before(:all) do
        get "/database/humongous_test/collection/local"
        @parsed_body = Crack::JSON.parse(last_response.body)
      end
    
      it "should give proper response" do
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
      end
    
      it "should contain proper key in json response" do
        @parsed_body.keys.should include("stats")
        @parsed_body.keys.should include("header")
      end
    
      it "should contain expected results" do
        @parsed_body["header"].should include("Collection humongous_test.local")
        @parsed_body["stats"].should == @collection.stats
      end
    end
    
    describe "update" do
      before(:all) do
        @doc["name"] = "test_changed"
        post "/database/humongous_test/collection/local/save", { doc: @doc }
        @parsed_body = Crack::JSON.parse(last_response.body)
      end
      
      it "should give proper response" do
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
      end
      
      it "should have saved document" do
        @parsed_body["status"].should == "OK"
        @parsed_body["saved"].should == true
      end
    end
  end
  
  describe "Collection Query" do
    
    before(:all) do
      @doc = @collection.insert({name: "test", age: 12})
      post "/database/humongous_test/collection/local/page/1", { query: "{ \"name\": \"test\" }", fields: "", skip: 0, limit: 10, sort: "[]" }
      @parsed_body = Crack::JSON.parse(last_response.body)
    end
    
    it "should give proper response" do
      last_response.should be_ok
      last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
    end
    
    it "should send back matched records" do
      @parsed_body.collect{|r| r["name"]}.all? {|t| t == "test" }.should == true
    end
    
  end
  
end
