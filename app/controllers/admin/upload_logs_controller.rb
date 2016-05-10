class Admin::UploadLogsController < ApplicationController
  before_filter :admin_required
  def aws
    @aws = AwsStatistics.new
    @datapoints =@aws.bucket_size_bytes.datapoints.sort_by{|i| i.timestamp}.reverse
  end
end
