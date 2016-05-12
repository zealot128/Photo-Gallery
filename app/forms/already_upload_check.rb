class AlreadyUploadCheck
  include ActiveModel::Model

  attr_accessor :files, :date

  def files=(var)
    @file_array = var.split("\n").map(&:strip)
    @files = var
  end

  def missing_files
    (@file_array - already_uploaded_files).sort
  end

  def already_uploaded_files
    (@file_array & possible_files).sort
  end

  private

  def possible_files
    @possible_files = BaseFile.where('created_at >= ?', date).pluck(:file)
  end
end
