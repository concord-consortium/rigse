module Labbook
  def self.enabled?
    (ENV['LABBOOK_PROVIDER_URL'] && !ENV['LABBOOK_PROVIDER_URL'].empty?) ? true : false
  end

  def self.url(learner_or_user, request, model=nil)
    if ENV['LABBOOK_PROVIDER_URL']
      id = "#{learner_or_user.id}"
      id += "-user" if learner_or_user.is_a?(User)
      id += "-#{model.class.to_s}-#{model.id}" if model
      "#{ENV['LABBOOK_PROVIDER_URL']}/albums?source=#{request.host}&user_id=#{Digest::MD5.hexdigest(id)}".gsub('//albums', '/albums')
    else
      nil
    end
  end
end