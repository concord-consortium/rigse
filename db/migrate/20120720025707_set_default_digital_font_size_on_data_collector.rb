class SetDefaultDigitalFontSizeOnDataCollector < ActiveRecord::Migration
  def up
    # set all the existing contents as having been extracted.
    execute "UPDATE embeddable_data_collectors SET dd_font_size = 30 WHERE dd_font_size IS NULL"
  end

  def down
  end
end
