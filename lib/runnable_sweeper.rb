class RunnableSweeper < ActionController::Caching::Sweeper
  observe Investigation, Section, Activity, Page, ExternalActivity, ResourcePage, PageElement, Embeddable::Diy::EmbeddedModel, Diy::Model

  # Used to enable observers for specific models and skip the others.
  # Should be an array of classes, eg [Section, Page, ResourcePage] or an empty array [] or nil.
  # If nil, all models will be observed.
  # If empty, no models will be observed.
  # Otherwise, a model will only be observed if the class exists in the array.
  # NOTE: This will not skip models within the recursive expire_cache_for method.
  cattr_accessor :enabled_models

  def after_create(runnable)
    expire_cache_for(runnable) if RunnableSweeper.enabled_models.nil? || RunnableSweeper.enabled_models.include?(runnable.class)
  end

  def after_update(runnable)
    expire_cache_for(runnable) if RunnableSweeper.enabled_models.nil? || RunnableSweeper.enabled_models.include?(runnable.class)
  end

  def after_destroy(runnable)
    expire_cache_for(runnable) if RunnableSweeper.enabled_models.nil? || RunnableSweeper.enabled_models.include?(runnable.class)
  end

  private

  def expire_cache_for(runnable, controller = ActionController::Base.new)
    return unless runnable
    # for some reason, calling expire_fragment directly didn't always work, so use a passed controller to ensure it works
    controller.expire_fragment(%r{_#{runnable.class.to_s}_#{runnable.id}_})

    # update the cached value of can_run_lightweight. use update_all to avoid triggering observers, validations, callbacks, etc.
    if runnable.respond_to? 'lightweight?'
      is_lightweight = runnable.can_run_lightweight?
      runnable.class.update_all("lightweight = '#{is_lightweight ? 1 : 0}'", ['id = ?', runnable.id])
    end

    #also expire any parent caches
    case runnable
    when Page
      expire_cache_for(runnable.find_section, controller)
    when Section
      expire_cache_for(runnable.activity, controller)
    when Activity
      expire_cache_for(runnable.investigation, controller)
    when PageElement
      expire_cache_for(runnable.page, controller)
    when Diy::Model
      runnable.embeddable_models.uniq.each do |em|
        expire_cache_for(em, controller)
      end
    when Embeddable::Diy::EmbeddedModel
      runnable.page_elements.uniq.each do |pe|
        expire_cache_for(pe, controller)
      end
    end
  end
end
