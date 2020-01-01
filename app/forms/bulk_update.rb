class BulkUpdate
  attr_reader :files

  def initialize(params, current_user)
    @files = BaseFile.where(id: params[:file_ids])
    @tag_ids = params[:tag_ids]
    @share_ids = params[:share_ids]
    @new_share = params[:new_share]
    @new_tag = params[:new_tag]
    @current_user = current_user
  end

  def save
    shares = Share.where(id: @share_ids).to_a
    if @new_share.present?
      shares += [Share.where(name: @new_share).first_or_create(user: @current_user)]
    end
    binding.pry
    tags = ActsAsTaggableOn::Tag.where(id: @tag_ids).to_a
    if @new_tag.present?
      tags += [ActsAsTaggableOn::Tag.where(name: @new_tag.strip.downcase).first_or_create]
    end
    @files.each do |file|
      shares.each do |share|
        file.shares << share unless file.shares.include?(share)
      end
      tags.each do |tag|
        file.tags << tag unless file.tags.include?(tag)
      end
    end
    true
  end
end
