require 'common'
class Converter
  CONVERTER_SLEEP = 5 unless defined? CONVERTER_SLEEP
  
  class QueueRequired < Exception; @message = "invalid query provided"; end
  class JobRequired < Exception; @message = "job required"; end
  
  attr_accessor :queue
  attr_accessor :sleep
  
  def initialize
    @uuid = UUID.new.generate
  end
  
  # daemon loop for periodically checking the queue
  # and converting the contents to mp3
  def go
    loop do
      begin
        check_for_job
        Kernel.sleep CONVERTER_SLEEP
      rescue QueueRequired
        App.log.info("error queue required")
      end
    end
  end
  
  # check for a job on the queue
  def check_for_job
    raise QueueRequired unless @queue
    job = @queue.pop
    process_job(job) if job
  end
  
  # process the job from the queue
  def process_job(job)
    status = write_to_s3(job) if convert(job)     
    job.cleanup
  end
  
  # convert text to mp3
  def convert(job)
    return false unless job && job.worthy?
    
    # handle job json or an instantiated job
    job = ConversionJob.load(job) unless job.is_a?(ConversionJob)
    
    # use the appropriate tts converter for the platform
    tts_command = case App.platform
      when "osx"
        "say -o #{job.wav_path} \"#{job.prepared_text}\""
      when "linux"
        "echo \"#{job.prepared_text}\" | text2wave -o #{job.wav_path}"
    end

    # execute the conversion and return the result
    command = "#{tts_command} && lame #{job.wav_path} #{job.mp3_path} && rm #{job.wav_path}"
    App.log.info(command)
    system(command)
  end
  
  # write the mp3 up to s3
  def write_to_s3(job)
    FileStore.write_to_s3(job.s3_path, job.mp3)
  end
  
end