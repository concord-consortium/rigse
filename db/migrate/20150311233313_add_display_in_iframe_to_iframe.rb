class AddDisplayInIframeToIframe < ActiveRecord::Migration
  def change
    add_column :embeddable_iframes, :display_in_iframe, :boolean, default: false
  end
end
