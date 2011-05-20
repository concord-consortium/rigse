require "zlib"
require 'b64'

module SailBundleContent

  EMPTY_EPORTFOLIO_BUNDLE_PATH = File.join(RAILS_ROOT, 'public', 'bundles', 'empty_bundle.xml')
  EMPTY_EPORTFOLIO_BUNDLE = File.read(EMPTY_EPORTFOLIO_BUNDLE_PATH)
  EMPTY_BUNDLE = "<sessionBundles />\n"
  VALID_CLOSING_ELEMENT = "</sessionBundles>"
  VALID_CLOSING_ELEMENT_INDEX = VALID_CLOSING_ELEMENT.length * -1

  def body
    self[:body] || EMPTY_BUNDLE
  end

  def eportfolio
    Dataservice::BundleLogger::OPEN_ELEMENT_EPORTFOLIO + self.body + Dataservice::BundleLogger::CLOSE_ELEMENT_EPORTFOLIO
  end

  def valid_xml?
    body[VALID_CLOSING_ELEMENT_INDEX..-1] == VALID_CLOSING_ELEMENT || body == EMPTY_BUNDLE
  end

  def empty?
    !body[/<sockEntries value=/]
  end
  
  def sock_entry_values
    body.scan(/<sockEntries value="(.*)"/).flatten
  end
end