class RunnableSweeper < ActionController::Caching::Sweeper
  observe Investigation, Section, Activity, Page, ExternalActivity, ResourcePage, PageElement

  def after_create(runnable)
    expire_cache_for(runnable)
  end

  def after_update(runnable)
    expire_cache_for(runnable)
  end

  def after_destroy(runnable)
    expire_cache_for(runnable)
  end

  private

  def expire_cache_for(runnable)
    expire_fragment(Regexp.new("_#{runnable.class.to_s}_#{runnable.id}_"))
  end
end
