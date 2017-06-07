class SqsQueueWorker
  class SqsApi
    def sqs
      @sqs ||= Aws::SQS::Client.new(CarrierWave::Uploader::Base.aws_credentials)
    end

    def queue_url
      @queue_url ||= @sqs.get_queue_url(queue_name: queue_name).queue_url
    end

    def queue_name
      Setting['sqs_queue_name']
    end

    def messages
      @messages ||= sqs.receive_message(queue_url: queue_url, max_number_of_messages: 10).messages
    end

    def delete_message(receipt_handle)
      sqs.delete_message(queue_url: queue_url, receipt_handle: receipt_handle)
    end
  end

  class S3Api
    def initialize
      @client = Aws::S3::Client.new(CarrierWave::Uploader::Base.aws_credentials)
      @bucket = Setting['aws.bucket']
    end

    def get_file(path)
      @client.get_object(bucket: @bucket, key: path)
    end

    def delete_file(path)
      @client.delete_object(bucket: @bucket, key: path)
    end

    def file_exists?(path)
      @client.head_object(bucket: @bucket, key: path)
    rescue Aws::S3::Errors::NotFound
      false
    end
  end

  def self.run
    api = SqsApi.new
    return if api.queue_name.blank?
    api.messages.each do |m|
      json = JSON.parse(m.body)['Records'].first
      if json['eventName'] != 'ObjectCreated:Put'
        api.delete_message(m.receipt_handle)
        next
      end
      if new(json).run
        api.delete_message(m.receipt_handle)
      end
    end
    nil
  end

  def initialize(message)
    @message = message
    @s3_api = S3Api.new
  end

  def run
    return unless @message['s3']['bucket']['name'] == Setting['aws.bucket']

    @key = @message['s3']['object']['key']
    tempfile = download_file(@key)
    md5 = Digest::MD5.file(tempfile).to_s
    if exists_and_present?(md5)
      return done!
    end
    user = User.first
    base_file = BaseFile.create_from_upload(tempfile, user)
    if base_file.valid?
      return done!
    end
    true
    # Keep file for inspection
  rescue Aws::S3::Errors::NoSuchKey
    true
  end

  def done!
    @s3_api.delete_file(@key)
    true
  end

  def exists_and_present?(md5)
    existing = BaseFile.find_by(md5: md5)
    return false unless existing
    @s3_api.file_exists?(existing.file.path)
  rescue Aws::S3::Errors::NotFound => _
    false
  end

  def download_file(key)
    file = @s3_api.get_file(key)
    tf = Tempfile.new(['sqs-', key.split('/').last])
    tf.binmode
    IO.copy_stream(file.body, tf)
    tf.flush
    tf
  end
end
