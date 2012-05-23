class Dataservice::PeriodicBundleLogger < ActiveRecord::Base
  self.table_name = :dataservice_periodic_bundle_loggers

  serialize :imports

  belongs_to :learner, :class_name => "Portal::Learner"
  has_many :periodic_bundle_contents, :class_name => "Dataservice::PeriodicBundleContent", :order => :created_at, :dependent => :destroy
  has_many :periodic_bundle_parts, :class_name => "Dataservice::PeriodicBundlePart", :order => :created_at, :dependent => :destroy

  ## FIXME How do we handle launch process events?

  def sail_bundle
    body = SailBundleContent::EMPTY_BUNDLE
    process_non_periodic_bundle if self.periodic_bundle_parts.size == 0 && self.learner.bundle_logger.last_non_empty_bundle_content != nil
    process_non_processed_bundles
    if self.periodic_bundle_parts.size > 0
      body = <<BODY
<sessionBundles xmlns:xmi="http://www.omg.org/XMI" xmlns:sailuserdata="sailuserdata" curnitUUID="cccccccc-0009-0000-0000-000000000000">
  <sockParts podId="dddddddd-0002-0000-0000-000000000000" rimName="ot.learner.data" rimShape="[B">
    <sockEntries value="#{B64Gzip.pack(otml)}" millisecondsOffset="12345"/>
  </sockParts>
  <agents role="RUN_WORKGROUP"/>
</sessionBundles>
BODY
    end

    bundle = <<HERE
#{Dataservice::BundleLogger::OPEN_ELEMENT_EPORTFOLIO}
#{body}
#{Dataservice::BundleLogger::CLOSE_ELEMENT_EPORTFOLIO}
HERE
  end

  def otml
    user_id = self.learner.uuid
    doc_id = UUIDTools::UUID.timestamp_create.to_s
    all_parts = self.periodic_bundle_parts
    delta_parts = all_parts.select {|p| p.delta }
    non_delta_parts = all_parts - delta_parts

    out = <<OTML
<?xml version="1.0" encoding="UTF-8"?>
<otrunk id="#{doc_id}">
  <imports>
    #{imports_otml}
  </imports>
  <objects>
    <OTStateRoot formatVersionString="1.0">
      <userMap>
        <entry key="#{user_id}">
          <OTReferenceMap>
            <user>
              <OTUserObject id="#{user_id}" />
            </user>
            #{map_otml(delta_parts, "map")}
            #{map_otml(non_delta_parts, "annotations")}
          </OTReferenceMap>
        </entry>
      </userMap>
    </OTStateRoot>
  </objects>
</otrunk>
OTML
  end

  private

  def imports_otml
    imps = (self.imports + ['org.concord.otrunk.OTStateRoot', 'org.concord.otrunk.user.OTUserObject', 'org.concord.otrunk.user.OTReferenceMap']).uniq
    imps.map{|i| %!    <import class="#{i}" />! }.join("\n")
  end
  
  def map_otml(parts, attr = "map")
    out = "            <#{attr}>\n"
    parts.each do |p|
      out << <<PART
              <entry key="#{p.key}">
                #{p.value}
              </entry>
PART
    end
    out << "            </#{attr}>"
    out
  end

  def process_non_periodic_bundle
    last_bundle = self.learner.bundle_logger.last_non_empty_bundle_content
    # create a "periodic" bundle out of it
    pbc = Dataservice::PeriodicBundleContent.create(:body => last_bundle.otml, :periodic_bundle_logger => self)
    pbc.extract_parts.invoke_job
    self.reload
  end

  def process_non_processed_bundles
    self.periodic_bundle_contents.where(:parts_extracted => false).each do |bc|
      bc.extract_parts.invoke_job
    end
  end
end
