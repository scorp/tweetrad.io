# =========================
# = Database connectivity =
# =========================
class DB
  cattr_reader :connection
  
  # CLASS METHODS
  class << self
    # create the database connection
    def setup_connection
      ActiveRecord::Base.establish_connection(YAML.load_file(File.join(APP_ROOT, "config", "database.yml")))
    end
    
    # build out the schema
    def prepare_schema
      tables = [];ActiveRecord::Base.connection.execute("show tables").each{|t| tables << t[0].strip}
      
      ActiveRecord::Schema.define do
        App.log.info("preparing schema")
        
        unless tables.include?("services")
          # a service entry
          begin
            create_table  :services do |t|
              t.string    :name
              t.string    :status,           :null => false, :default => "active"
            end
            add_index :services, :name
          rescue
            App.log_exception
          end
        end
        
        unless tables.include?("queries")
          begin
            # queries
            create_table  :queries do |t|
              t.string    :query         
              t.column    :last_twid, :bigint, :null => false, :default => 0
              t.timestamp :last_run
              t.integer   :last_result_count
              t.string    :status, :default => 'active', :null=> false
            end
            add_index :queries, :query
          rescue
            App.log_exception
          end
        end
        
        unless tables.include?("tweets")
          begin
            # cache of tweets
            create_table :tweets do |t|
              t.column    :twid, :bigint, :null => false
              t.string    :from_user
              t.string    :to_user
              t.integer   :from_user_id
              t.integer   :to_user_id
              t.string    :text
              t.string    :profile_image_url
              t.timestamp :created_at
            end
            add_index :tweets, :twid
          rescue
            App.log_exception
          end
        end
        
      end # define schema
    end # prepare schema
  end # class methods
end # class
DB.setup_connection