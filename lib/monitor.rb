# ==============================================
# = in charge of monitoring size of s3 buckets =
# ==============================================
class Monitor
  PREFERRED_LISTING_SIZE = 250
  MAX_LISTING_SIZE = 1000
  attr_reader :query
  
  def query=(query)
    return unless query
    @folder = S3Folder.new(query)
  end

  def check_folder
    return unless @folder
    App.log.info("checking folder: #{@folder.name}")
    listing = @folder.listing.reverse
    if listing.size > PREFERRED_LISTING_SIZE
      (listing[PREFERRED_LISTING_SIZE..-1] || []).each_with_index do |key, index|
        key.delete if Time.parse(key.headers["date"]).utc > 30.minutes.ago.utc || index > MAX_LISTING_SIZE
      end
    else
      App.log.info("nothing needs to be done at the moment")
    end
  rescue
    App.log_exception
  end

end