module HasEmbeddables

  # Classes mixing in this module must provide `page_elements` association
  def self.included(clazz)

    clazz.class_eval do
      has_many :multiple_choices,
        -> { order id: :asc },
        through: :page_elements,
        source: :embeddable,
        source_type: Embeddable::MultipleChoice.to_s

      has_many :iframes,
        -> { order id: :asc },
        through: :page_elements,
        source: :embeddable,
        source_type: Embeddable::Iframe.to_s

      # Called by Investigation, this generates a Query like this:
      # SELECT `embeddable_open_responses`.* FROM `embeddable_open_responses`
      #   INNER JOIN `page_elements` ON `embeddable_open_responses`.`id` = `page_elements`.`embeddable_id`
      #   INNER JOIN `pages` ON `page_elements`.`page_id` = `pages`.`id`
      #   INNER JOIN `sections` ON `pages`.`section_id` = `sections`.`id`
      #   INNER JOIN `activities` ON `sections`.`activity_id` = `activities`.`id`
      # WHERE
      #   `page_elements`.`embeddable_type` = 'Embeddable::OpenResponse'
      #   AND `activities`.`investigation_id` = 1
      # ORDER BY
      #   `embeddable_open_responses`.`id` ASC,
      #   page_elements.position ASC,
      #   page_elements.id ASC,
      #   `pages`.`position` ASC,
      #   `sections`.`position` ASC,
      #   `activities`.`position` ASC
      has_many :open_responses,
        -> { order id: :asc },
        through: :page_elements,
        source: :embeddable,
        source_type: Embeddable::OpenResponse.to_s


      has_many :image_questions,
        -> { order id: :asc },
        through: :page_elements,
        source: :embeddable,
        source_type: Embeddable::ImageQuestion.to_s
    end
  end

end
