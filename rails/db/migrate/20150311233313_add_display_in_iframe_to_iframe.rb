class AddDisplayInIframeToIframe < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_iframes, :display_in_iframe, :boolean, default: false
  end
end
