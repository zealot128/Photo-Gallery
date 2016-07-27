class Admin::UploadLogsController < ApplicationController
  before_action :admin_required

  def index
    @logs = UploadLog.order('created_at desc').limit(100)
  end

  def aws
    @aws = AwsStatistics.new
    binding.pr
    @datapoints =@aws.bucket_size_bytes.datapoints.sort_by{|i| i.timestamp}.reverse
  end
end
