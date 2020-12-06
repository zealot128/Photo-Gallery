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
      ],
      "AWS" => [
        rekognition_check,
      ]
    }
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
