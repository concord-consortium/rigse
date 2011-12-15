class RunnableSweeper < ActionController::Caching::Sweeper
  observe Investigation, Section, Activity, Page, ExternalActivity, ResourcePage

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
    return unless runnable
    expire_fragment(Regexp.new("_#{runnable.class.to_s}_#{runnable.id}_"))

    #also expire any parent caches
    case runnbale
    when Page
      expire_cache_for(runnable.find_section)
    when Section
      expire_cache_for(runnable.activity)
    when Activity
      expire_cache_for(runnable.investigation)
    when PageElement
      expire_cache_for(runnable.page)
    end
  end
end
