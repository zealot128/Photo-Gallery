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
end
