class Dataservice::Blob < ActiveRecord::Base
  self.table_name = :dataservice_blobs

  belongs_to :bundle_content, :class_name => "Dataservice::BundleContent", :foreign_key => "bundle_content_id"
  belongs_to :periodic_bundle_content, :class_name => "Dataservice::PeriodicBundleContent", :foreign_key => "periodic_bundle_content_id"
  # lightweight learners create blobs directly (without a bundle content...)
  belongs_to :lightweight_learner, :class_name => "Portal::Learner", :foreign_key => "learner_id"
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
    return attributes['mimetype'] if attributes['mimetype']
    return "image/png" if content =~ /^.PNG/
    return "application/octet-stream"
  end

  def file_extension
    return self.attributes['file_extension'] if self.attributes['file_extension']
    case self.mimetype
    when "image/png"
      return "png"
    when "application/octet-stream"
    end
    return "blob"
  end

  def html_content(path_to_self)
    case self.mimetype
    when /image/
      return "<img src='#{path_to_self}' />"
    when "application/octet-stream"
      return "<div>Unknown binary content</div>"
    end
    return "<div>Unknown binary content</div>"
  end

  def content=(new_content)
    if new_content != self.content
      write_attribute(:content,new_content)
      compute_checksum
    end
  end

  def checksum
    return attributes['checksum'] if attributes['checksum']
    compute_checksum
  end

  def compute_checksum
    digest = Digest::SHA1.new
    digest << (self.content         || "")
    digest << (self.learner_id.to_s || "")
    self.checksum = digest.to_s
  end

  def load_content_from(url)
    return if url.blank?
    web_client = HTTPClient.new
    response = web_client.get(url)
    if HTTP::Status.successful?(response.status)
      self.mimetype = response.contenttype
      self.content  = response.content
    end
  end

  def self.for_learner_and_url(learner, url)
    new_blob = self.new(:lightweight_learner => learner)
    new_blob.load_content_from(url)
    found = self.find_by_checksum(new_blob.checksum)
    return found if found;
    new_blob.save!
    return new_blob
  end

end
