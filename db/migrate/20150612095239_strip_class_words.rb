class StripClassWords < ActiveRecord::Migration
  class Portal::Clazz < ActiveRecord::Base
    self.table_name = 'portal_clazzes'
  end

  def up
    Portal::Clazz.where('class_word like " %" OR class_word like "% "').each do |c|
      c.update_attributes!(class_word: c.class_word.strip)
    end
  end

  def down
  end
end
