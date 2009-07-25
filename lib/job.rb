class ConversionJob
  
  class << self
    def load(json)
      ConversionJob.new(JSON.parse(json))
    end
  end
  
  
  attr_reader :uuid
  attr_accessor :text
  
  def initialize(data)
    @uuid = data["uuid"] || UUID.new.generate
    @text = data["text"]
  end
  
  def to_json
    {
      "uuid" => @uuid,
      "text" => @text
    }.to_json
  end
  
  # return the file name for the given extension
  def filename(extension)
    "/tmp/#{@uuid}.#{extension}"
  end
  
  def wav_path
    filename("wav")
  end
  
  def mp3_path
    filename("mp3")
  end
  
  def mp3
    File.read(filename("mp3"))
  end
  
  def cleanup
    FileUtils.rm(filename("mp3"))
  end
  
end