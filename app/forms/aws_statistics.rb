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
end
