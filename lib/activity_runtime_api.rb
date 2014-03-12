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

  def self.republish(hash)
    # use hash['type'] to determine what to build
    if hash['type'] == 'Activity'
      external_activity = self.update_activity(hash)
    elsif hash['type'] == 'Sequence'
      external_activity = self.update_sequence(hash)
    else
      raise ActivityRuntimeAPIError, "Submitted data must declare a type"
    end
    raise(ActivityRuntimeAPIError, "Activity not found") unless external_activity
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
      # update activity so external_activity.template is correctly initialzed
      # otherwise external_activity.template.is_template? won't be true
      activity.reload
    end

    return external_activity
  end

  def self.find(url)
    return nil if url.blank?
    return ExternalActivity.where(:url => url).first
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
    iq_cache = {}

    investigation.multiple_choices.each do |multiple_choice|
      mc_cache[multiple_choice.external_id] = multiple_choice
    end

    investigation.open_responses.each do |open_response|
      or_cache[open_response.external_id] = open_response
    end

    investigation.image_questions.each do |image_question|
      iq_cache[image_question.external_id] = image_question
    end

    # remove the pages and sections
    (investigation.sections + investigation.pages).each do |section|
      section.delete
    end

    # Update or build sections, pages and embeddables
    build_page_components(hash, activity, user, or_cache, mc_cache, iq_cache)

    # delete the cached items which weren't removed
    mc_cache.each_value { |v| v.destroy }
    or_cache.each_value { |v| v.destroy }
    iq_cache.each_value { |v| v.destroy }
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
      # update investigation so external_activity.template is correctly initialzed
      # otherwise external_activity.template.is_template? won't be true
      investigation.reload
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
    iq_cache = {}

    investigation.multiple_choices.each do |multiple_choice|
      mc_cache[multiple_choice.external_id] = multiple_choice
    end

    investigation.open_responses.each do |open_response|
      or_cache[open_response.external_id] = open_response
    end

    investigation.image_questions.each do |image_question|
      iq_cache[image_question.external_id] = image_question
    end

    # remove the pages and sections
    (investigation.sections + investigation.pages).each do |section|
      section.delete
    end

    # Now the investigation has shallow activities; cache those
    activity_cache = {}
    investigation.activities.each do |act|
      activity_cache[act.name] = act
      act.investigation_id = nil
    end

    # Add hashed activities back in to investigation
    hash['activities'].each do |new_activity|
      existing = activity_cache.delete(new_activity['name'])
      if existing
        build_page_components(new_activity, existing, user, or_cache, mc_cache, iq_cache)
        existing.investigation = investigation
      else
        activity = activity_from_hash(new_activity, investigation, user)
      end
    end

    # delete the cached items which weren't removed
    mc_cache.each_value { |v| v.destroy }
    or_cache.each_value { |v| v.destroy }
    iq_cache.each_value { |v| v.destroy }
    activity_cache.each_value { |v| v.destroy }

    return external_activity
  end

  def self.activity_from_hash(hash, investigation, user)
    activity = Activity.create(:name => hash["name"], :user => user, :investigation => investigation)
    build_page_components(hash, activity, user)
    return activity
  end

  def self.build_page_components(hash, activity, user, or_cache=nil, mc_cache=nil, iq_cache=nil)
    # Validate caches so we don't do it repeatedly later
    or_cache = {} unless or_cache.kind_of?(Hash)
    mc_cache = {} unless mc_cache.kind_of?(Hash)
    iq_cache = {} unless iq_cache.kind_of?(Hash)

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
            existant = or_cache.delete(element_data["id"].to_s) # nil if the key doesn't exist - note the key must be string
            if existant
              update_open_response(element_data, existant)
            else
              create_open_response(element_data, user)
            end
          when "multiple_choice"
            existant = mc_cache.delete(element_data["id"].to_s)
            if existant
              update_mc_response(element_data, existant)
            else
              create_multiple_choice(element_data, user)
            end
          when "image_question"
            existant = iq_cache.delete(element_data["id"].to_s)
            if existant
              update_image_question(element_data, existant)
            else
              create_image_question(element_data, user)
            end
          else
            # We don't support this type, so skip to the next
            next
          end
          # Either the 'existant' or output of create_#{} has been assigned to 'embeddable'

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

  def self.update_image_question(iq_data, existant)
    existant.update_attributes(
      :prompt => iq_data["prompt"],
      :drawing_prompt => iq_data["drawing_prompt"]
    )
    return existant
  end

  def self.create_image_question(iq_data, user)
    Embeddable::ImageQuestion.create(
      :prompt => iq_data["prompt"],
      :drawing_prompt => iq_data["drawing_prompt"],
      :external_id => iq_data["id"],
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
    new_choice_set = []
    mc_data["choices"].each do |choice_data|
      id = choice_data["id"]
      choice   = cached_choices.delete(id)
      choice.reload if choice
      choice ||= Embeddable::MultipleChoiceChoice.create(:external_id => id)
      choice.update_attributes(
        :multiple_choice => mc,
        :choice => choice_data["content"],
        :is_correct => choice_data["correct"]
      )
      new_choice_set << choice
    end
    mc.choices = new_choice_set
    mc.save
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
