class ActivityRuntimeAPIError < StandardError
end

class ActivityRuntimeAPI

  def self.publish(hash, user)
    # First version only published activities
    # TODO: update_activities
    external_activity = self.update_activity(hash) || self.publish_activity(hash,user)
    return external_activity
  end

  def self.publish2(hash, user)
    # use hash['type'] to determine what to build
    if hash['type'] == 'Activity'
      external_activity = self.update_activity(hash) || self.publish_activity(hash,user)
    elsif hash['type'] == 'Sequence'
      external_activity = self.update_sequence(hash) || self.publish_sequence(hash, user)
    else
      raise ActivityRuntimeAPIError, "Submitted data must declare a type"
    end
    return external_activity
  end


  private

  def self.publish_activity(hash, user)
    external_activity = nil
    Investigation.transaction do
      investigation = Investigation.create(:name => hash["name"], :user => user)
      activity = activity_from_hash(hash, investigation, user)
      external_activity = ExternalActivity.create(
        :name             => hash["name"],
        :description      => hash["description"],
        :url              => hash["url"],
        :launch_url  => hash["launch_url"] || hash["create_url"],
        :template         => activity,
        :publication_status => "published",
        :user => user
      )
    end

    return external_activity
  end

  def self.find(url)
    return nil if url.blank?
    return ExternalActivity.find(:first, :conditions => {:url => url})
  end


  def self.update_activity(hash)
    external_activity = self.find(hash["url"])
    return nil unless external_activity
    activity = external_activity.template
    investigation = activity.investigation
    user = investigation.user


    # update the simple attributes
    [investigation, activity, external_activity].each do |act|
      ['name','description'].each do |attribute|
        act.update_attribute(attribute,hash[attribute])
      end
    end

    # save the embeddables
    mc_cache = {}
    or_cache = {}

    investigation.multiple_choices.each do |multiple_choice|
      mc_cache[multiple_choice.external_id] = multiple_choice
    end

    investigation.open_responses.each do |open_response|
      or_cache[open_response.external_id] = open_response
    end

    # TODO: Image questions

    # remove the pages and sections
    (investigation.sections + investigation.pages).each do |section|
      section.delete
    end

    # Update or build sections, pages and embeddables
    build_page_components(hash, activity, user, or_cache, mc_cache)

    # delete the cached items which werent removed
    mc_cache.each_value { |v| v.destroy }
    or_cache.each_value { |v| v.destroy }
    return external_activity
  end

  def self.publish_sequence(hash, user)
    external_activity = nil # Why are we initializing this? For the transaction?
    Investigation.transaction do
      investigation = Investigation.create(:name => hash["name"], :description => hash['description'], :user => user)
      hash['activities'].each do |act|
        activity_from_hash(act, investigation, user)
      end
      external_activity = ExternalActivity.create(
        :name             => hash["name"],
        :description      => hash["description"],
        :url              => hash["url"],
        :launch_url  => hash["launch_url"] || hash["create_url"],
        :template         => investigation,
        :publication_status => "published",
        :user => user
      )

    end

    return external_activity
  end

  def self.update_sequence(hash)
    external_activity = self.find(hash["url"])
    return nil unless external_activity
    if external_activity.template.is_a?(Investigation)
      investigation = external_activity.template
    else
      # The URL in the hash isn't for a sequence.
      raise ActivityRuntimeAPIError, "URL and kind values don't match."
    end
    user = external_activity.user

    # update the simple attributes
    [investigation, external_activity].each do |act|
      ['name','description'].each do |attribute|
        act.update_attribute(attribute,hash[attribute])
      end
    end

    # save the embeddables
    mc_cache = {}
    or_cache = {}

    investigation.multiple_choices.each do |multiple_choice|
      mc_cache[multiple_choice.external_id] = multiple_choice
    end

    investigation.open_responses.each do |open_response|
      or_cache[open_response.external_id] = open_response
    end

    # TODO: Image questions

    # remove the pages and sections
    (investigation.sections + investigation.pages).each do |section|
      section.delete
    end

    # Now the investigation has shallow activities; cache those
    activity_cache = {}
    investigation.activities.each do |act|
      activity_cache[act.url] = act
      act.investigation_id = nil
    end

    # Add hashed activities back in to investigation
    hash['activities'].each do |new_activity|
      existing = activity_cache.delete(new_activity['url'])
      if existing
        build_page_components(new_activity, existing, user, or_cache, mc_cache)
        existing.investigation = investigation
      else
        activity = activity_from_hash(new_activity, investigation, user)
      end
    end

    # delete the cached items which weren't removed
    mc_cache.each_value { |v| v.destroy }
    or_cache.each_value { |v| v.destroy }
    activity_cache.each_value { |v| v.destroy }

    return external_activity
  end

  def self.activity_from_hash(hash, investigation, user)
    activity = Activity.create(:name => hash["name"], :user => user, :investigation => investigation)
    build_page_components(hash, activity, user)
    return activity
  end

  def self.update_activity_from_hash(hash)
  end

  def self.build_page_components(hash, activity, user, or_cache=nil, mc_cache=nil)
    hash["sections"].each do |section_data|
      section = Section.create(
        :name => section_data["name"],
        :activity => activity,
        :user => user
      )

      section_data["pages"].each do |page_data|
        page = Page.create(
          :name => page_data["name"],
          :section => section,
          :user => user
        )

        page_data["elements"].each do |element_data|
          embeddable = case element_data["type"]
          when "open_response"
            existant = or_cache ? or_cache.delete(element_data["id"]) : nil
            if existant
              update_open_response(element_data, existant)
            else
              create_open_response(element_data, user)
            end
          when "multiple_choice"
            existant = mc_cache ? mc_cache.delete(element_data["id"]) : nil
            if existant
              update_mc_response(element_data, existant)
            else
              create_multiple_choice(element_data, user)
            end
          else
            next
          end

          page.add_embeddable(embeddable)
        end
      end
    end
  end

  def self.update_open_response(or_data, existant)
    existant.update_attributes(
      :prompt => or_data["prompt"]
    )
    return existant
  end

  def self.create_open_response(or_data, user)
    Embeddable::OpenResponse.create(
      :prompt => or_data["prompt"],
      :external_id => or_data["id"],
      :user => user
    )
  end

  def self.update_mc_response(mc_data, existant)
    existant.update_attributes(
      :prompt => mc_data["prompt"],
      :allow_multiple_selection => mc_data["allow_multiple_selection"]
    )
    self.add_choices(existant,mc_data)
    return existant
  end

  def self.add_choices(mc, mc_data)
    cached_choices = { }

    mc.choices.each do |choice|
      cached_choices[choice.external_id] = choice
    end
    mc.choices = []
    mc.save
    mc_data["choices"].each do |choice_data|
      id = choice_data["id"]
      choice   = cached_choices.delete(id)
      # when the choices list was emptied then all of the choices were modified
      choice.reload if choice
      choice ||= Embeddable::MultipleChoiceChoice.create(:external_id => id)
      choice.update_attributes(
        :multiple_choice => mc,
        :choice => choice_data["content"],
        :is_correct => choice_data["correct"]
      )
    end
  end

  def self.create_multiple_choice(mc_data, user)
    mc = Embeddable::MultipleChoice.create(
      :prompt => mc_data["prompt"],
      :external_id => mc_data["id"],
      :allow_multiple_selection => mc_data["allow_multiple_selection"],
      :user => user
    )
    self.add_choices(mc,mc_data)

    return mc
  end
end
