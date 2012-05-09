require 'nokogiri'

class Dataservice::PeriodicBundleContent < ActiveRecord::Base
  set_table_name :dataservice_periodic_bundle_contents

  belongs_to :periodic_bundle_logger, :class_name => "Dataservice::PeriodicBundleLogger"

  def extract_parts
    pbl = self.periodic_bundle_logger
    otml = Nokogiri::XML(self.body)

    # extract the imports and merge them into the bundle logger's import list
    existing_imports = pbl.imports || []
    new_imports = []
    imports = otml.xpath("/otrunk/imports/import")
    imports.each do |imp|
      k = imp['class']
      new_imports << k
    end
    new_different_imports = (new_imports - existing_imports)
    if new_different_imports.size > 0
      pbl.imports ||= []
      pbl.imports += new_different_imports
      pbl.save
    end

    # extract all of the entry chunks and save them as Dataservice::PeriodicBundleParts
    entries = otml.xpath("/otrunk/objects/OTReferenceMap/map/entry")
    entries.each do |entry|
      key = entry['key']
      value = entry.children.to_xml.strip
      part = Dataservice::PeriodicBundlePart.find_or_create_by_periodic_bundle_logger_id_and_key(:periodic_bundle_logger_id => pbl.id, :key => key)
      part.value = value
      part.save
    end
  end
  handle_asynchronously :extract_pieces

  def extract_saveables
    ## TODO
  end
  handle_asynchronously :extract_saveables

  def copy_to_collaborators
    ## TODO
  end
  handle_asynchronously :copy_to_collaborators
end
