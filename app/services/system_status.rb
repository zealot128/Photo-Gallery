class SystemStatus
  class Check
    attr_reader :title, :error, :status, :optional
    def initialize(title:, error: nil, status:, optional: true)
      @title = title
      @error = error
      @status = status
      @optional = optional
    end
  end

  def checks
    {
      "System" => [
        system_storage_check,
        Check.new(title: "FFMPeg installed", status: Setting.vips_installed? ? 'success' : 'error', optional: false),
        Check.new(title: "VIPS installed", status: Setting.vips_installed? ? 'success' : 'error', optional: false),
        Check.new(title: "Tesseract installed", status: Setting.tesseract_installed? ? 'success' : 'danger'),
        sidekiq_check,
      ],
      "AWS" => [
        s3_storage_check,
        rekognition_check,
        *s3_budgets,
      ]
    }
  end

  def s3_storage_check
    storage = Shrine.find_storage(:aws)
    storage.bucket.objects.first
    Check.new(title: "S3 Access to bucket #{storage.bucket.name} successful", status: 'success', optional: false)
  rescue StandardError => e
    Check.new(title: "S3 Access to bucket #{storage.bucket.name} unsuccessful: #{e.inspect}", status: 'danger', optional: false)
  end

  def s3_budgets
    budgets = AwsStatistics.new.budgets
    unless budgets.first
      return Check.new(title: "No AWS Budget found for account", status: 'warning', optional: true)
    end

    budgets.map do |budget|
      if budget.calculated_spend.forecasted_spend
        fore = budget.calculated_spend.forecasted_spend.amount.to_f * 100 / budget.budget_limit.amount.to_f
        status = case fore
                 when 0..80
                   'success'
                 when 80..100
                   'warning'
                 else
                   'danger'
                 end
        forecast = "Forecast: #{budget.calculated_spend.forecasted_spend.amount} #{budget.calculated_spend.actual_spend.unit}, #{fore.round}%"
      else
        status = 'success'
        forecast = ""
      end

      title = "Budget: #{budget.budget_name},<br>" \
              "#{budget.calculated_spend.actual_spend.amount.to_f.round} #{budget.calculated_spend.actual_spend.unit} / " \
              "#{budget.budget_limit.amount} #{budget.budget_limit.unit}, <br> #{forecast}"

      Check.new(title: title.html_safe, status: status, optional: true)
    end
  rescue NoMethodError => e
    raise e
  rescue StandardError => e
    Check.new(title: "Error while accessing Budgets: #{e.inspect}", status: 'warning', optional: true)
  end

  def sidekiq_check
    # count = (Sidekiq::ScheduledSet.new.count + Sidekiq::Queue.new.count)
    # Check.new(title: "Sidekiq running (#{count} jobs in queue)", status: Sidekiq::ProcessSet.new.size > 0 ? 'success' : 'danger', optional: false)
  end

  def system_storage_check
    s = Sys::Filesystem.stat(Rails.root.to_s)
    available = ((s.block_size * s.blocks_available) / 1.gigabyte.to_f).round(2)
    total = ((s.block_size * s.blocks) / 1.gigabyte.to_f).round(2)
    Check.new(
      title: "Free System Storage: #{available} GB / #{total} GB",
      optional: false,
      status: if available > 10
                'success'
              elsif available > 2
                'warning'
              else
                'danger'
              end
    )
  end

  def rekognition_check
    unless RekognitionClient.rekognition_collection
      return Check.new(title: "Face Rekognition: No face rekognition collection set", status: 'danger', optional: true)
    end

    RekognitionClient.collection

    Check.new(title: "Face Rekognition: Collection access successful", status: 'success', optional: true)
  rescue StandardError => e
    Check.new(title: "Face Rekognition: Error while accessing: #{e.inspect}", status: 'danger', optional: true)
  end
end
