require 'common'
class ConversionJob
  
  class << self
    def load(json)
      ConversionJob.new(JSON.parse(json))
    end
  end
  
  def initialize(data)
    @data = data
    @data["uuid"] ||= UUID.new.generate
  end
  
  # accessor for the data hash
  def method_missing(name, *args)
    @data[name.to_s] || nil
  end
  
  # cleanup the tweet for the conversion
  def prepared_text
    text.gsub(/"/,"").gsub(/http:\/\/.*\b/,"").strip
  end
  
  # is this tweet worthy of tweetrad.io?
  def worthy?
    true
  end
  
  # return the file name for the given extension
  def filename(extension)
    "/tmp/#{uuid}.#{extension}"
  end
  
  # path for the local wav file
  def wav_path
    filename("wav")
  end
  
  # path for the local mp3 file
  def mp3_path
    filename("mp3")
  end
  
  # where to write the mp3 for this job on s3
  def s3_path
    "#{queue_id}/#{uuid}.mp3"
  end
  
  # read the mp3 file
  def mp3(location=:local)
    if location == :local
      File.read(filename("mp3"))
    else
      # TODO read from s3
    end
  end
  
  # remove the local mp3 file
  def cleanup
    FileUtils.rm(filename("mp3"))
  end
  
  # serialize to json
  def to_json
    @data.to_json
  end
  
end