require 'nokogiri'

class Dataservice::PeriodicBundleContent < ActiveRecord::Base
  set_table_name :dataservice_periodic_bundle_contents

  belongs_to :periodic_bundle_logger, :class_name => "Dataservice::PeriodicBundleLogger"

  def extract_parts
    self.periodic_bundle_logger = self.periodic_bundle_logger
    otml = Nokogiri::XML(self.body)

    extract_imports(otml)

    extract_entries(otml)
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

  def extract_imports(otml = Nokogiri::XML(self.body))
    # extract the imports and merge them into the bundle logger's import list
    existing_imports = self.periodic_bundle_logger.imports || []
    new_imports = []
    imports = otml.xpath("/otrunk/imports/import")
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

  def extract_entries(otml = Nokogiri::XML(self.body))
    # extract all of the entry chunks and save them as Dataservice::PeriodicBundleParts
    entries = otml.xpath("/otrunk/objects/OTReferenceMap/map/entry")
    entries.each do |entry|
      key = entry['key']
      extract_non_delta_parts(entry.children.first, otml)
      value = entry.children.to_xml.strip
      part = Dataservice::PeriodicBundlePart.find_or_create_by_periodic_bundle_logger_id_and_key(:periodic_bundle_logger_id => self.periodic_bundle_logger.id, :key => key)
      part.value = value
      part.save
    end
  end

  def extract_non_delta_parts(element, otml)
    element.xpath('.//*[@id]').each do |child|
      # first create a part for this child
      key = part['id']
      part = Dataservice::PeriodicBundlePart.find_or_create_by_periodic_bundle_logger_id_and_key(:periodic_bundle_logger_id => self.periodic_bundle_logger.id, :key => key)
      part.value = child.to_s
      part.delta = false
      part.save

      # now replace this child with an object reference
      obj_ref = Nokogiri::XML::Node.new "object", otml
      obj_ref['refid'] = key
      child.replace(obj_ref)
    end
  end
end
