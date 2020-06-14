require 'nokogiri'

class Dataservice::PeriodicBundleContent < ActiveRecord::Base
  self.table_name = :dataservice_periodic_bundle_contents

  belongs_to :periodic_bundle_logger, :class_name => "Dataservice::PeriodicBundleLogger"
  delegate :learner, :to => :periodic_bundle_logger, :allow_nil => true

  has_many :blobs, :class_name => "Dataservice::Blob", :foreign_key => "periodic_bundle_content_id"

  attr_accessor :skip_collaborators

  before_create :process_bundle
  # If the body has a OTStateRoot, it means it was a non-periodic bundle imported to initialize old learner data.
  # Don't copy these to collaborators since they likely have their own non-periodic bundles which will be imported.
  after_create :copy_to_collaborators, :unless => Proc.new {|pbc| pbc.skip_collaborators || pbc.empty? || pbc.has_state_root? }

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

  def delayed_process_bundle
    extract_parts
    extract_saveables
  end

  def extract_parts
    return true if self.parts_extracted

    doc = Nokogiri::XML(self.body)

    extract_imports(doc)

    extract_entries(doc)

    self.parts_extracted = true
    self.save
  end

  def extract_saveables
    raise "PeriodicBundleContent ##{self.id}: body is empty!" if self.empty
    extractor = Otrunk::ObjectExtractor.new(self.body)
    extract_everything(extractor)

    # Also create/update a Report::Learner object for reporting
    self.learner.report_learner.update_fields if self.learner
  end

  def copy_to_collaborators
    return true unless self.learner && self.learner.offering
    return true unless (bundle = self.learner.bundle_logger.in_progress_bundle)
    return true unless (collabs = bundle.collaborators).size > 0
    # Make sure that we copy data to other learners only once, when we process bundle
    # that belongs to collaboration owner. Otherwise we would have started endless copy cycle.
    return true unless bundle.collaboration_owner_bundle?
    collabs.each do |student|
      # Do not replicate bundle that already exists (+ the same issue as above - endless copy cycle).
      next if student == bundle.owner
      slearner = self.learner.offering.find_or_create_learner(student)
      new_bundle_logger = slearner.periodic_bundle_logger

      # by calling sail_bundle on this student's periodic_bundle_logger
      # we cause the most recent non-periodic bundle to get processed prior to
      # creating their first periodic bundle
      new_bundle_logger.sail_bundle if new_bundle_logger.periodic_bundle_parts.size == 0 && slearner.bundle_logger.last_non_empty_bundle_content != nil

      new_attributes = self.attributes.merge({
        :skip_collaborators => true,
        :processed => false,
        :periodic_bundle_logger_id => new_bundle_logger.id
      })
      bundle_content = Dataservice::PeriodicBundleContent.create(new_attributes)
      new_bundle_logger.periodic_bundle_contents << bundle_content
      new_bundle_logger.reload
    end
    true # make sure to return true or we can get caught in an endless copy cycle
  end

  def has_state_root?
    self.body =~ /OTStateRoot/
  end

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
      part = Dataservice::PeriodicBundlePart.where(:periodic_bundle_logger_id => self.periodic_bundle_logger.id, :key => key).first_or_create
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
      part = Dataservice::PeriodicBundlePart.where(:periodic_bundle_logger_id => self.periodic_bundle_logger.id, :key => key).first_or_create
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
