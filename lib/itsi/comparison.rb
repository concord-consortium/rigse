module ITSI
  class Comparison

    def self.activity_hash(activity)
      h, order = activity_hash_with_ordering(activity)
      return h
    end

    def self.activity_hash_with_ordering(activity)
      h = {}
      section_order = [:name, :description]
      embeddable_order = []
      return h unless activity && activity.is_a?(Activity)
      h[:name] = activity.name
      h[:description] = activity.description
      activity.sections.each do |section|
        section_order.push(section.name)
        h[section.name] = { :enabled => section.is_enabled? }
        next unless section.is_enabled?
        section.pages.each do |page|
          page.page_elements.each_with_index do |element, i|
            embeddable = element.embeddable
            data = hash_for_element(element)
            embeddable_order.push("#{embeddable.class}_#{i}")
            h[section.name]["#{embeddable.class}_#{i}"] = data if data
          end
        end
      end
      return [h, [section_order, embeddable_order, keys_for_elements]]
    end

    private

    def self.keys_for_elements
      # Depends on the type...
      # These are hand-picked based on what's exposed in the authoring UI
      [
        # Embeddable::Diy::Section
        :content,
        # Embeddable::OpenResponse
        :prompt, :default_response,
        # Embeddable::DrawingTool
        :background_image_url,
        # Embeddable::Diy::Sensor
        :prototype_id, :multiple_graphable_enabled,
        # Embeddable::Diy::EmbeddedModel
        :diy_model_id
      ]
    end

    def self.hash_for_element(element)
      h = nil
      if element.is_enabled?
        h = {}
        embeddable = element.embeddable
        keys_for_elements.each do |k|
          h[k] = embeddable.send(k) if embeddable.respond_to?(k)
        end
      end

      puts "No comparable attributes for type: #{embeddable.class.to_s}" if h && h.keys.size == 0

      return h
    end
  end
end
