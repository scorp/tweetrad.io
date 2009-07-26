# =============================
# = represents a folder on s3 =
# =============================
class S3Folder
  
  attr_reader :name, :folder_path
  
  def initialize(query)
    @name = query
    @folder_path = Digest::MD5.hexdigest(query)
  end
  
  def listing
    keys = FileStore.s3_bucket.keys({:prefix => @folder_path}, true)
    keys.sort_by{|f| Time.parse(f.headers["date"])}.reverse
  end

  def folder_size
    listing.size
  end
  
end