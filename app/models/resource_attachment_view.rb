class ResourceAttachmentView < ActiveRecord::Base
  belongs_to :resource_page
  belongs_to :attached_file
end
