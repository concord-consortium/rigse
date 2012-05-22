require 'nokogiri'

class Dataservice::PeriodicBundleContent < ActiveRecord::Base
  self.table_name = :dataservice_periodic_bundle_contents

  belongs_to :periodic_bundle_logger, :class_name => "Dataservice::PeriodicBundleLogger"
  delegate :learner, :to => :periodic_bundle_logger, :allow_nil => true

  has_many :blobs, :class_name => "Dataservice::Blob", :foreign_key => "periodic_bundle_content_id"

  before_create :process_bundle

  include BlobExtraction
  include SaveableExtraction

  def otml
    read_attribute :body
  end

  def otml=(val)
    write_attribute(:body, val)
  end

  def process_bundle
    doc = Nokogiri::XML(self.body)
    self.record_bundle_processing
    self.valid_xml = !(doc.errors.any?)
    # Calculate self.empty even when the xml is missing or invalid
    self.empty = self.body.nil? || self.body.empty? || ((map = doc.xpath('/otrunk/objects//OTReferenceMap/map').first) && map.element_children.size == 0)
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
    raise "PeriodicBundleContent ##{self.id}: body is empty!" if self.empty
    extractor = Otrunk::ObjectExtractor.new(self.body)
    extract_everything(extractor)

    # Also create/update a Report::Learner object for reporting
    Report::Learner.for_learner(self.learner).update_fields
  end
  handle_asynchronously :extract_saveables

  def copy_to_collaborators
    return unless self.learner && self.learner.offering
    return unless (bundle = self.learner.bundle_logger.in_progress_bundle)
    return unless (collabs = bundle.collaborators).size > 0
    collabs.each do |student|
      slearner = self.learner.offering.find_or_create_learner(student)
      new_bundle_logger = slearner.periodic_bundle_logger

      # by calling sail_bundle on this student's periodic_bundle_logger
      # we cause the most recent non-periodic bundle to get processed prior to
      # creating their first periodic bundle
      new_bundle_logger.sail_bundle if new_bundle_logger.periodic_bundle_parts.size == 0 && slearner.bundle_logger.last_non_empty_bundle_content != nil

      new_attributes = self.attributes.merge({
        :processed => false,
        :periodic_bundle_logger => new_bundle_logger
      })
      bundle_content = Dataservice::PeriodicBundleContent.create(new_attributes)
      new_bundle_logger.periodic_bundle_contents << bundle_content
      new_bundle_logger.reload
    end
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
    entries = doc.xpath("/otrunk/objects//OTReferenceMap/map/entry")
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
    @seen ||= []
    element.xpath('.//*[@id]').each do |child|
      # first extract non-delta parts for all children of this child
      # so that when we store this child's content, those objects have
      # been replaced with object references
      extract_non_delta_parts(child, doc)

      next if @seen.include?(child)
      @seen << child

      # then create a part for this child
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
