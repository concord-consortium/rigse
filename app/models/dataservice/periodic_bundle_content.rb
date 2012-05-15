require 'nokogiri'

class Dataservice::PeriodicBundleContent < ActiveRecord::Base
  self.table_name = :dataservice_periodic_bundle_contents

  belongs_to :periodic_bundle_logger, :class_name => "Dataservice::PeriodicBundleLogger"
  has_many :blobs, :class_name => "Dataservice::Blob", :foreign_key => "periodic_bundle_content_id"

  before_create :process_bundle

  include BlobExtraction

  def otml
    read_attribute :body
  end

  def otml=(val)
    write_attribute(:body, val)
  end

  def process_bundle
    doc = Nokogiri::XML(self.body)
    self.record_bundle_processing
    self.valid_xml = doc.errors.any?
    # Calculate self.empty even when the xml is missing or invalid
    self.empty = self.body.nil? || self.body.empty? || ((map = doc.xpath('/otrunk/objects/OTReferenceMap/map').first) && map.element_children.size == 0)
    self.extract_blobs unless self.empty
    true # don't stop the callback chain.
  end

  def record_bundle_processing
    self.updated_at = Time.now
    self.processed = true
  end

  def extract_parts
    self.periodic_bundle_logger = self.periodic_bundle_logger
    doc = Nokogiri::XML(self.body)

    extract_imports(doc)

    extract_entries(doc)
  end
  handle_asynchronously :extract_parts

  def extract_saveables
    ## TODO
  end
  handle_asynchronously :extract_saveables

  def copy_to_collaborators
    ## TODO
  end
  handle_asynchronously :copy_to_collaborators

  private

  def extract_imports(doc = Nokogiri::XML(self.body))
    # extract the imports and merge them into the bundle logger's import list
    existing_imports = self.periodic_bundle_logger.imports || []
    new_imports = []
    imports = doc.xpath("/otrunk/imports/import")
    imports.each do |imp|
      k = imp['class']
      new_imports << k
    end
    new_different_imports = (new_imports - existing_imports)
    if new_different_imports.size > 0
      self.periodic_bundle_logger.imports ||= []
      self.periodic_bundle_logger.imports += new_different_imports
      self.periodic_bundle_logger.save
    end
  end

  def extract_entries(doc = Nokogiri::XML(self.body))
    # extract all of the entry chunks and save them as Dataservice::PeriodicBundleParts
    entries = doc.xpath("/otrunk/objects/OTReferenceMap/map/entry")
    entries.each do |entry|
      key = entry['key']
      extract_non_delta_parts(entry.element_children.first, doc)
      value = entry.children.to_xml.strip
      part = Dataservice::PeriodicBundlePart.find_or_create_by_periodic_bundle_logger_id_and_key(:periodic_bundle_logger_id => self.periodic_bundle_logger.id, :key => key)
      part.value = value
      part.save
    end
  end

  def extract_non_delta_parts(element, doc)
    element.xpath('.//*[@id]').each do |child|
      # first create a part for this child
      key = child['id']
      part = Dataservice::PeriodicBundlePart.find_or_create_by_periodic_bundle_logger_id_and_key(:periodic_bundle_logger_id => self.periodic_bundle_logger.id, :key => key)
      part.value = child.to_s
      part.delta = false
      part.save

      # now replace this child with an object reference
      obj_ref = Nokogiri::XML::Node.new "object", doc
      obj_ref['refid'] = key
      child.replace(obj_ref)
    end
  end
end
