require 'sys/filesystem'
class AwsStatistics
  attr_reader :client
  def initialize
    @client = Aws::CloudWatch::Client.new( CarrierWave::Uploader::Base.aws_credentials )
  end

  def bucket
    CarrierWave::Uploader::Base.aws_bucket
  end

  def disk_usage
    @disk_usage ||=
      begin
        s = Sys::Filesystem.stat("/")
        upload = `du -hs public/system/* public/photos/*`.split("\n").map{|i| i.split(' ') }
        {
          available: (s.block_size * s.blocks_available) / 1.gigabyte.to_f,
          total: (s.block_size * s.blocks) / 1.gigabyte.to_f,
          upload_dir: upload
        }
      end
  end

  def bucket_size_bytes
    client.get_metric_statistics(namespace: 'AWS/S3',
                                 metric_name: 'BucketSizeBytes',
                                 statistics: ['Average', 'Sum'],
                                 dimensions: [
                                   {
                                     name: "BucketName",
                                     value: bucket
                                   },
                                   {
                                     name: "StorageType",
                                     value: "StandardStorage"
                                   }
                                 ],
                                 # region: CarrierWave::Uploader::Base.aws_credentials[:region],
                                 start_time: 4.weeks.ago,
                                 end_time: Time.now,
                                 period: 1.day
                                )
  end

  def rekognition_collection_size
    next_token = nil
    total_count = 0
    loop do
      print 'x'
      response = RekognitionClient.collection(max_results: 4000, next_token: next_token)
      total_count += response.faces.length
      if response.next_token
        next_token = response.next_token
      else
        break
      end
    end
    total_count
  end

  def account_id
    id = Setting['aws.account_id']
    id && id.to_s
  end

  def budgets
    return [] unless account_id
    Aws::Budgets::Client.new(CarrierWave::Uploader::Base.aws_credentials).describe_budgets(account_id: account_id).try(:budgets)
  rescue Aws::Budgets::Errors::AccessDeniedException
    []
  end
end
