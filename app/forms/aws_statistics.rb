class AwsStatistics
  attr_reader :client
  def initialize
    @client = Aws::CloudWatch::Client.new( CarrierWave::Uploader::Base.aws_credentials )
  end

  def bucket
    CarrierWave::Uploader::Base.aws_bucket
  end

  def bucket_size_bytes
    # bucket = 'swi-pictures-production'
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
