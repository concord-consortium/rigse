class Dataservice::Blob < ActiveRecord::Base
  set_table_name :dataservice_blobs

  belongs_to :bundle_content, :class_name => "Dataservice::BundleContent", :foreign_key => "bundle_content_id"
  belongs_to :periodic_bundle_content, :class_name => "Dataservice::PeriodicBundleContent", :foreign_key => "periodic_bundle_content_id"

  before_create :create_token

  def create_token
    # create a random string which will be used to verify permission to view this blob
    self.token = UUIDTools::UUID.timestamp_create.hexdigest
  end

  include Changeable

  # pagination default
  cattr_reader :per_page
  @@per_page = 5

  self.extend SearchableModel

  @@searchable_attributes = %w{content}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

  end

  def name
    return "#{self.id}: #{self.mimetype}"
  end

  # IF you add more auto-detectable mime-types, be sure to add an html representation in the html_content method,
  # and add support in the Dataservice::BlobsController#show action.
  def mimetype
    return "image/png" if content =~ /^.PNG/
    return "application/octet-stream"
  end

  def file_extension
    case self.mimetype
    when "image/png"
      return "png"
    when "application/octet-stream"
    end
    return "blob"
  end

  def html_content(path_to_self)
    case self.mimetype
    when "image/png"
      return "<img src='#{path_to_self}' />"
    when "application/octet-stream"
      return "<div>Unknown binary content</div>"
    end
    return "<div>Unknown binary content</div>"
  end
end
