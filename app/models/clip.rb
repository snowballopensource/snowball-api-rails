class Clip < ActiveRecord::Base
  belongs_to :reel

  has_attached_file :video
  validates_attachment_presence :video
  validates_attachment_file_name :video, matches: [/mp4\Z/]
end