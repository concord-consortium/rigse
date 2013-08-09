class Labbook
  def self.enabled?
    (ENV['LABBOOK_PROVIDER_URL'] && !ENV['LABBOOK_PROVIDER_URL'].empty?) ? true : false
  end
end