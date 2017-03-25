class TubeController < ApplicationController
  before_action :login_required

  def index
    @videos = Video.order('shot_at desc').paginate(per_page: 100, page: params[:page])
    @json = @videos.map { |video|
      {
				name: video.read_attribute("file"),
        poster: video.file.url(:preview),
				thumbnail: [
					{
						src: video.file.url(:preview)
					}
				],
        sources: [
          {
            src: video.file.url(:large),
            type: 'video/mp4'
          }, {
            src: video.file.url,
            type: 'video/mp4'
          }
        ],
      }
    }
  end
end
