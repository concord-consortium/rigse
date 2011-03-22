module Portal::OfferingsHelper
  def learner_data_report(offering)
    default_class = offering.runnable.offerings.select {|x| x.clazz.default_class == true }
  end
end
