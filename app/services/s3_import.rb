class S3Import
  class S3Api
    def initialize(max: 5)
      @client = Aws::S3::Client.new(CarrierWave::Uploader::Base.aws_credentials)
      @bucket = Setting['aws.bucket']
      @max = 5
    end

    def get_file(path)
      @client.get_object(bucket: @bucket, key: path)
    end

    def delete_file(path)
      @client.delete_object(bucket: @bucket, key: path)
    end

    def list_objects(prefix)
      @client.list_objects(prefix: prefix, bucket: @bucket, max_keys: @max).contents
    end

    def file_exists?(path)
      @client.head_object(bucket: @bucket, key: path)
    rescue Aws::S3::Errors::NotFound
      false
    end
  end

  def self.run(max: 5, folder: 'incoming/')
    api = S3Api.new(max: max)
    api.list_objects('incoming/').select { |i| i.size > 0 }.each do |file|
      new(file).run
    end
  end

  def initialize(file)
    @file = file
    @s3_api = S3Api.new
    @key = file.key
  end

  def run
    tempfile = download_file
    md5 = Digest::MD5.file(tempfile).to_s
    if exists_and_present?(md5)
      return done!
    end
    user = User.first
    base_file = BaseFile.create_from_upload(tempfile, user)
    if base_file.valid?
      return done!
    end
  rescue Aws::S3::Errors::NoSuchKey
  end

  def done!
    @s3_api.delete_file(@key)
  end

  def exists_and_present?(md5)
    existing = BaseFile.find_by(md5: md5)
    return false unless existing
    @s3_api.file_exists?(existing.file.path)
  rescue Aws::S3::Errors::NotFound => _
    false
  end

  def download_file
    file = @s3_api.get_file(@key)
    tf = Tempfile.new(['sqs-', @key.split('/').last])
    tf.binmode
    IO.copy_stream(file.body, tf)
    tf.flush
    tf
  end
end
