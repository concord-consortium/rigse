class ActivityRuntimeAPI

  def self.publish(hash, user)
    external_activity = self.update(hash) || self.create(hash,user)
    return external_activity
  end

  def self.publish2(hash, user)
    true
  end


  private

  def self.create(hash, user)
    external_activity = nil
    Investigation.transaction do
      investigation = Investigation.create(:name => hash["name"], :user => user)
      activity = Activity.create(:name => hash["name"], :user => user, :investigation => investigation)
      external_activity = ExternalActivity.create(
        :name             => hash["name"],
        :description      => hash["description"],
        :url              => hash["url"],
        :launch_url  => hash["launch_url"] || hash["create_url"],
        :template         => activity,
        :publication_status => "published",
        :user => user
      )

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
              create_open_response(element_data, user)
            when "multiple_choice"
              create_multiple_choice(element_data, user)
            else
              next
            end

            page.add_embeddable(embeddable)
          end
        end
      end
    end

    return external_activity
  end

  def self.find(url)
    return nil if url.blank?
    return ExternalActivity.find(:first, :conditions => {:url => url})
  end


  def self.update(hash)
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

    # remove the pages and sections
    (investigation.sections + investigation.pages).each do |section|
      section.delete
    end

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
            existant = or_cache.delete(element_data["id"])
            if existant
              update_open_response(element_data, existant)
            else
              create_open_response(element_data, user)
            end
          when "multiple_choice"
            existant = mc_cache.delete(element_data["id"])
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
    # delete the cached items which werent removed
    mc_cache.each_value { |v| v.destroy }
    or_cache.each_value { |v| v.destroy }
    return external_activity
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
