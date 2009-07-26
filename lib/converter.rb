class Converter
  attr_accessor :queue
  
  def initialize
  end
  
  # check for a job on the queue
  def check_for_job
    unless @queue
      App.log.info("nothing to do...so bored")
      return
    end
    message = @queue.pop
    return unless message
    job = ConversionJob.load(message.body)
    process_job(job) if job
  end
  
  # process the job from the queue
  def process_job(job)
    status = write_to_s3(job) if convert(job)     
    job.cleanup
  end
  
  # convert text to mp3
  def convert(job)
    return false unless job
    # handle job json or an instantiated job
    job = ConversionJob.load(job) unless job.is_a?(ConversionJob)
    return false unless job.worthy? # is this job worthy of conversion
    
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
    FileStore.write_to_s3(job.s3_path, job.mp3, {
      "job" => job.to_json
    })
  end
  
end