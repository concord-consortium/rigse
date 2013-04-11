module Dataservice::BlobsHelper
  def blob_url_for(answer)
    dataservice_blob_raw_url(:id => answer[:blob].id, :token => answer[:blob].token)
  end
end