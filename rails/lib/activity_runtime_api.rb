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

  def self.create_tool(source_type)
    tool = Tool.where(source_type: source_type).first
    return tool if tool
    Tool.create(source_type: source_type, name: source_type)
  end

  def self.publish_activity(hash, user)
    external_activity = nil
    Investigation.transaction do
      external_activity = ExternalActivity.create(
        :tool                   => create_tool(hash["source_type"] || "LARA"),
        :name                   => hash["name"],
        :url                    => hash["url"],
        :thumbnail_url          => hash["thumbnail_url"],
        :launch_url             => hash["launch_url"] || hash["create_url"],
        :author_url             => hash["author_url"],
        :print_url              => hash["print_url"],
        :student_report_enabled => hash["student_report_enabled"],
        :publication_status     => "published",
        :user                   => user,
        :author_email           => hash["author_email"],
        :is_locked              => hash["is_locked"]
      )
      self.setup_activity_template(external_activity, hash)
      # 2019-07-12 NP: Lara no longer manages external reports ...
      # self.update_external_report(external_activity,hash["external_report_url"])
    end
    return external_activity
  end

  def self.setup_activity_template(external_activity, hash)
    investigation = Investigation.create(:name => hash["name"], :user => external_activity.user)
    external_activity.template = activity_from_hash(hash, investigation, external_activity.user)
    external_activity.save!
  end

  def self.find(url)
    return nil if url.blank?
    return ExternalActivity.where(:url => url).first
  end


  def self.update_activity(hash)
    external_activity = self.find(hash["url"])
    return nil unless external_activity
    # If ExternalActivity already exists, it might not have template correctly set yet.
    # It happens when ExternalActivity is duplicated.
    unless external_activity.template
      self.setup_activity_template(external_activity, hash)
    end
    activity = external_activity.template
    investigation = activity.investigation
    user = investigation.user

    # update the simple attributes
    [investigation, activity, external_activity].each do |act|
      ['name', 'thumbnail_url'].each do |attribute|
        act.update_attribute(attribute, hash[attribute])
      end
    end

    ['author_email', 'is_locked', 'print_url', 'author_url', 'student_report_enabled'].each do |attribute|
      external_activity.update_attribute(attribute,hash[attribute])
    end

    # 2019-07-12 NP: Lara no longer manages external reports ...
    # self.update_external_report(external_activity,hash["external_report_url"])

    # save the embeddables
    mc_cache = {}
    or_cache = {}
    iq_cache = {}
    if_cache = {}

    investigation.multiple_choices.each do |multiple_choice|
      mc_cache[multiple_choice.external_id] = multiple_choice
    end

    investigation.open_responses.each do |open_response|
      or_cache[open_response.external_id] = open_response
    end

    investigation.image_questions.each do |image_question|
      iq_cache[image_question.external_id] = image_question
    end

    investigation.iframes.each do |iframe|
      if_cache[iframe.external_id] = iframe
    end

    # remove the pages and sections
    (investigation.sections + investigation.pages).each do |section|
      section.delete
    end

    # Update or build sections, pages and embeddables
    build_page_components(hash, activity, user, or_cache, mc_cache, iq_cache, if_cache)

    # delete the cached items which weren't removed
    mc_cache.each_value { |v| v.destroy }
    or_cache.each_value { |v| v.destroy }
    iq_cache.each_value { |v| v.destroy }
    if_cache.each_value { |v| v.destroy }
    remove_report_embeddable_filters(external_activity)
    return external_activity
  end

  def self.publish_sequence(hash, user)
    external_activity = nil # Why are we initializing this? For the transaction?
    Investigation.transaction do
      external_activity = ExternalActivity.create(
        :tool                   => create_tool(hash["source_type"] || "LARA"),
        :name                   => hash["name"],
        :url                    => hash["url"],
        :thumbnail_url          => hash["thumbnail_url"],
        :launch_url             => hash["launch_url"] || hash["create_url"],
        :author_url             => hash["author_url"],
        :print_url              => hash["print_url"],
        :publication_status     => "published",
        :user                   => user,
        :author_email           => hash["author_email"],
        :is_locked              => hash["is_locked"]
      )
      self.setup_sequence_template(external_activity, hash)
      # 2019-07-12 NP: Lara no longer manages external reports ...
      # self.update_external_report(external_activity, hash["external_report_url"])
    end
    return external_activity
  end

  def self.setup_sequence_template(external_activity, hash)
    investigation = Investigation.create(
      :name => hash["name"],
      :user => external_activity.user
    )
    all_student_reports_enabled = true
    # acts_as_list uses 1-based indexing on position
    hash['activities'].each.with_index(1) do |act, index|
      activity_from_hash(act, investigation, external_activity.user, index)
      # a sequence has its student_report_enabled set to false if any of its activities have it set to false
      all_student_reports_enabled &&= (act.has_key?("student_report_enabled") ? act["student_report_enabled"] : true)
    end
    external_activity.student_report_enabled = all_student_reports_enabled
    external_activity.template = investigation
    external_activity.save!
  end

  def self.update_sequence(hash)
    external_activity = self.find(hash["url"])
    return nil unless external_activity
    # If ExternalActivity already exists, it might not have template correctly set yet.
    # It happens when ExternalActivity is duplicated.
    unless external_activity.template
      self.setup_sequence_template(external_activity, hash)
    end
    if external_activity.template.is_a?(Investigation)
      investigation = external_activity.template
    else
      # The URL in the hash isn't for a sequence.
      raise ActivityRuntimeAPIError, "URL and kind values don't match."
    end
    user = external_activity.user

    # update the simple attributes
    [investigation, external_activity].each do |act|
      ['name', 'thumbnail_url'].each do |attribute|
        act.update_attribute(attribute, hash[attribute])
      end
    end

    ['author_email', 'is_locked', 'print_url', 'author_url', 'student_report_enabled'].each do |attribute|
      external_activity.update_attribute(attribute,hash[attribute]) if hash.has_key?(attribute)
    end

    # 2019-07-12 NP: Lara no longer manages external reports ...
    # self.update_external_report(external_activity, hash["external_report_url"])

    # save the embeddables
    mc_cache = {}
    or_cache = {}
    iq_cache = {}
    if_cache = {}

    investigation.multiple_choices.each do |multiple_choice|
      mc_cache[multiple_choice.external_id] = multiple_choice
    end

    investigation.open_responses.each do |open_response|
      or_cache[open_response.external_id] = open_response
    end

    investigation.image_questions.each do |image_question|
      iq_cache[image_question.external_id] = image_question
    end

    investigation.iframes.each do |iframe|
      if_cache[iframe.external_id] = iframe
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

    # Add hashed activities back in to investigation. Note that order
    # of activities in this hash defines order of activities in portal.
    # acts_as_list uses 1-based index values for position
    hash['activities'].each.with_index(1) do |new_activity, index|
      existing = activity_cache.delete(new_activity['name'])
      if existing
        build_page_components(new_activity, existing, user, or_cache, mc_cache, iq_cache, if_cache)
        existing.investigation = investigation
        existing.position = index
        existing.save!
      else
        activity = activity_from_hash(new_activity, investigation, user, index)
      end
    end

    # delete the cached items which weren't removed
    mc_cache.each_value { |v| v.destroy }
    or_cache.each_value { |v| v.destroy }
    iq_cache.each_value { |v| v.destroy }
    if_cache.each_value { |v| v.destroy }
    activity_cache.each_value { |v| v.destroy }

    remove_report_embeddable_filters(external_activity)
    external_activity.reload # e.g. updates activities list in case of need
    return external_activity
  end

  def self.activity_from_hash(hash, investigation, user, position = 1)
    # NOTE: It seems like we don't copy thumbnail url.
    # is this the right behavior for the report template?
    activity = Activity.create({
      :name => hash["name"],
      :position => position,
      :user => user,
      :investigation => investigation
    })
    build_page_components(hash, activity, user)
    return activity
  end

  def self.build_page_components(hash, activity, user, or_cache=nil, mc_cache=nil, iq_cache=nil, if_cache=nil)
    # Validate caches so we don't do it repeatedly later
    or_cache = {} unless or_cache.kind_of?(Hash)
    mc_cache = {} unless mc_cache.kind_of?(Hash)
    iq_cache = {} unless iq_cache.kind_of?(Hash)
    if_cache = {} unless if_cache.kind_of?(Hash)

    hash["sections"].each_with_index do |section_data, section_index|
      section = Section.create(
        :name => section_data["name"],
        :activity => activity,
        :user => user,
        :position => section_index
      )

      section_data["pages"].each_with_index do |page_data, page_index|
        page = Page.create(
          :name => page_data["name"],
          :url => page_data["url"],
          :section => section,
          :user => user,
          :position => page_index
        )

        page_data["elements"].each_with_index do |element_data, element_index|
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
          when "iframe_interactive"
            existant = if_cache.delete(element_data["id"].to_s)
            if existant
              update_iframe(element_data, existant)
            else
              create_iframe(element_data, user)
            end
          else
            # We don't support this type, so skip to the next
            next
          end
          # Either the 'existant' or output of create_#{} has been assigned to 'embeddable'
          page.add_embeddable(embeddable, element_index)
        end
      end
    end
  end

  # Use default val provided by DB when given attribute is not provided (nil)
  def self.optional_attrs (data, *attr_list)
    attrs = {}
    attr_list.each do |attr|
      attrs[attr] = data[attr] unless data[attr].nil?
    end
    attrs
  end

  def self.update_open_response(or_data, existant)
    attrs = {
      prompt: or_data["prompt"]
    }.merge(
      optional_attrs(or_data, "is_required", "show_in_featured_question_report")
    )
    existant.update_attributes(attrs)
    return existant
  end

  def self.create_open_response(or_data, user)
    attrs = {
      prompt: or_data["prompt"],
      external_id: or_data["id"],
      user: user
    }.merge(
      optional_attrs(or_data, "is_required", "show_in_featured_question_report")
    )
    Embeddable::OpenResponse.create(attrs)
  end

  def self.update_image_question(iq_data, existant)
    attrs = {
      prompt: iq_data["prompt"],
      drawing_prompt: iq_data["drawing_prompt"]
    }.merge(
      optional_attrs(iq_data, "is_required", "show_in_featured_question_report")
    )
    existant.update_attributes(attrs)
    return existant
  end

  def self.create_image_question(iq_data, user)
    attrs = {
      :prompt => iq_data["prompt"],
      :drawing_prompt => iq_data["drawing_prompt"],
      :external_id => iq_data["id"],
      :user => user
    }.merge(
      optional_attrs(iq_data, "is_required", "show_in_featured_question_report")
    )
    Embeddable::ImageQuestion.create(attrs)
  end

  def self.update_mc_response(mc_data, existant)
    attrs = {
      prompt: mc_data["prompt"],
      allow_multiple_selection: mc_data["allow_multiple_selection"]
    }.merge(
      optional_attrs(mc_data, "is_required", "show_in_featured_question_report")
    )
    existant.update_attributes(attrs)
    self.add_choices(existant, mc_data)
    return existant
  end

  def self.create_multiple_choice(mc_data, user)
    attrs = {
      prompt: mc_data["prompt"],
      external_id: mc_data["id"],
      allow_multiple_selection: mc_data["allow_multiple_selection"],
      user: user
    }.merge(
      optional_attrs(mc_data, "is_required", "show_in_featured_question_report")
    )
    mc = Embeddable::MultipleChoice.create(attrs)
    self.add_choices(mc, mc_data)
    return mc
  end

  def self.add_choices(mc, mc_data)
    cached_choices = { }

    mc.choices.each do |choice|
      cached_choices[choice.external_id] = choice
    end
    new_choice_set = []
    mc_data["choices"].each do |choice_data|
      id = choice_data["id"].to_s
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

  def self.update_iframe(if_data, existant)
    attrs = {
      name: if_data["name"],
      url: if_data["url"],
      width: if_data["native_width"],
      height: if_data["native_height"]
    }.merge(
      optional_attrs(if_data, "is_required", "show_in_featured_question_report", "display_in_iframe")
    )
    existant.update_attributes(attrs)
    return existant
  end

  def self.create_iframe(if_data, user)
    attrs = {
      name: if_data["name"],
      url: if_data["url"],
      width: if_data["native_width"],
      height: if_data["native_height"],
      external_id: if_data["id"].to_s,
      user: user
    }.merge(
      optional_attrs(if_data, "is_required", "show_in_featured_question_report", "display_in_iframe")
    )
    Embeddable::Iframe.create(attrs)
  end

  def self.remove_report_embeddable_filters(external_activity)
    template = external_activity.template
    filters = template.offerings.to_a.map { |offering| offering.report_embeddable_filter }.compact
    filters.each { |filter| filter.clear }
  end


end
