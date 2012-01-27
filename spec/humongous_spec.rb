require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

describe 'Humongous' do

  describe "misc" do
    it{ Humongous.version.should ==  Humongous::VERSION }
    
    it "should return proper description" do
      Humongous.description.should include("Humongous: A Ruby way to browse and maintain mongo instance. Using HTML5.")
    end

    it "should give proper summary" do
      Humongous.summary.should == %Q{An standalone Mongo Browser for Ruby. Just run and forget.}
    end
  end
  
  describe "Application" do

    include Rack::Test::Methods

    def app
      Humongous::Application
    end
  
    before(:all) do
      @connection = Mongo::Connection.new()#from_uri("mongodb://localhost:27017")
      @connection.add_auth("admin", "admin", "admin")
      @connection.apply_saved_authentication
      @database = @connection.db("humongous_test")
      @collection = @database.create_collection("local")
      @collection.insert({:name => "test", :age => 12})
      @doc = @collection.find_one({:name => "test"})
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
          @parsed_body = JSON.parse(last_response.body)
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

      describe "Create" do
        before(:all) do
          post '/database', {"database_name" => "humongo_test_create"}
          @parsed_body = JSON.parse(last_response.body)
        end
    
        it "should give proper response" do
          last_response.should be_ok
          last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
        end
    
        it "should contain proper key in json response" do
          @parsed_body.keys.should include("status")
          @parsed_body.keys.should include("created")
          @parsed_body.keys.should include("name")
        end
    
        it "should contain expected results" do
          @parsed_body["status"].should include("OK")
          @parsed_body["created"].should == true
          @parsed_body["name"].should == "humongo_test_create"
        end
      end
      
      describe "Delete" do

        before(:all) do
          @database = @connection.db("humongous_delete_test")
          @collection = @database.create_collection("local")
          delete "/database/humongous_delete_test"
          @parsed_body = JSON.parse(last_response.body)
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
          @parsed_body = JSON.parse(last_response.body)
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
          @parsed_body["stats"].should == JSON.parse(@collection.stats.to_json)
        end
      end
    
      describe "update" do
        before(:all) do
          @doc["name"] = "test_changed"
          post "/database/humongous_test/collection/local/save", { :doc => @doc }
          @parsed_body = JSON.parse(last_response.body)
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
    
    describe "Create" do
      
      before(:all) do
        post "/database/humongous_test/collection", { :collection_name => "humongous_test_create" }
        @parsed_body = JSON.parse(last_response.body)
      end
    
      it "should give proper response" do
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
      end
  
      it "should contain proper key in json response" do
        @parsed_body.keys.should include("status")
        @parsed_body.keys.should include("created")
        @parsed_body.keys.should include("name")
      end
  
      it "should contain expected results" do
        @parsed_body["status"].should include("OK")
        @parsed_body["created"].should == true
        @parsed_body["name"].should == "humongous_test_create"
      end
    end
    
    describe "Delete" do
      before(:all) do
        delete "/database/humongous_test/collection/humongous_test_create"
        @parsed_body = JSON.parse(last_response.body)
      end
      
      it "should give proper response" do
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
      end
  
      it "should contain proper key in json response" do
        @parsed_body.keys.should include("status")
        @parsed_body.keys.should include("dropped")
      end
  
      it "should contain expected results" do
        @parsed_body["status"].should include("OK")
        @parsed_body["dropped"].should == true
      end
    end
    
    describe "Create a Record" do
      before(:all) do
        post "/database/humongous_test/collection/local/insert", { :doc => "{\"name\" : \"humongous\", \"age\": \"42\" }" }
        @parsed_body = JSON.parse(last_response.body)
      end
      
      it "should give proper response" do
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
      end
  
      it "should contain proper key in json response" do
        @parsed_body.keys.should include("created")
        @parsed_body.keys.should include("id")
        @parsed_body.keys.should include("status")
      end
  
      it "should contain expected results" do
        @parsed_body["status"].should include("OK")
        @parsed_body["id"].should be_an_instance_of String
      end
    end
    
    describe "Delete a Record" do
      before(:all) do
        delete "/database/humongous_test/collection/test/remove", { :remove_query => "" }
        @parsed_body = JSON.parse(last_response.body)
      end
      
      it "should give proper response" do
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
      end
      
      it "should contain proper key in json response" do
        @parsed_body.keys.should include("status")
        @parsed_body.keys.should include("removed")
      end
      
      it "should contain expected results" do
        @parsed_body["status"].should include("OK")
        @parsed_body["removed"].should == true
      end
    end
  
    describe "Collection Query" do
    
      before(:all) do
        @doc = @collection.insert({:name => "test", :age => 12})
        post "/database/humongous_test/collection/local/page/1", { :query => "{ \"name\": \"test\" }", :fields => "", :skip => 0, :limit => 10, :sort => "[]" }
        @parsed_body = JSON.parse(last_response.body)
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
  
end
