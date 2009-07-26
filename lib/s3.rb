class FileStore
  class << self
    def copy_on_s3(current_path, destination_path)
      s3_bucket.copy_key(current_path, destination_path)
    end
    
    def fetch_from_s3(path)
      begin
        s3_bucket.get(path)
      rescue RightAws::AwsError => e
        App.log.info("aws not found : #{path}")
        return false
      end
    end
    
    def head_from_s3(path)
      begin
        s3.head(s3_bucket.name, path)
      rescue RightAws::AwsError => e
        App.log.info("aws not found : #{path}")
        return false
      end
    end
    
    def write_to_s3(path, data, meta_headers={})
      started_at = Time.now
      App.log.info("starting s3 write at #{started_at}")
      s3_bucket.put(path, data, meta_headers)
      finished_at = Time.now
      App.log.info("#{finished_at} total time #{finished_at - started_at}")
    end
    
    def delete_from_s3(path)
      s3_key(path).delete
    end
    
    def delete_folder_from_s3(folder)
      s3_bucket.delete_folder(folder)
    end
    
    def s3_key(path, head=false)
      s3_bucket.key(path, head)
    end

    def s3_bucket
      s3.bucket(App.aws_bucket,true,'public-read')
    end
    
    # used for generating expiring urls
    def s3_gen_bucket
      s3_gen.bucket(App.aws_bucket,true)
    end
    
    def s3
      @s3 ||= RightAws::S3.new(
        App.aws_access_id,
        App.aws_secret_key, 
        {
          :multi_thread=>true, 
          :protocol => "http", 
          :port => 80
        })
    end

    def s3_gen
      @s3_generator ||= RightAws::S3Generator.new(
        App.aws_access_id,
        App.aws_secret_key, 
        {
          :multi_thread=>true, 
          :protocol => "http", 
          :port => 80
        })
    end
    
  end
end