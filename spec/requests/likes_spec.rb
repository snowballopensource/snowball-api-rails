require 'rails_helper'

RSpec.describe 'Clips', type: :request do
  describe 'POST /clips/:clip_id/likes' do
    it 'likes the clip' do
      clip = create(:clip)
      post "/v1/clips/#{clip.id}/likes", {}, authenticated_env
      expect(response).to have_http_status(201)
      expect(Like.count).to eq(1)
    end
  end

  describe 'DELETE /clips/:clip_id/likes' do
    it 'unlikes the clip' do
      clip = create(:clip)
      create(:like, clip: clip, user: clip.user)
      delete "/v1/clips/#{clip.id}/likes", {}, authenticated_env
      expect(response).to have_http_status(204)
      expect(Like.count).to eq(0)
    end
  end
end
