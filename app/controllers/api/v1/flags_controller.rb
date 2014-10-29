class Api::V1::FlagsController < ApiController
  before_action :authenticate!
  before_action :set_clip

  def create
    @clip.flags.create!
    head :created
  end

  private

  def set_clip
    @clip = Clip.find(params[:clip_id])
  end
end