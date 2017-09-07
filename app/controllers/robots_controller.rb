class RobotsController < ApplicationController
  
  layout false

  def index
    if ENV['DYNAMIC_ROBOTS_TXT'] == 'true'

        lines = []

        lines = [
            "#",
            "# This file is dynamically generated.",
            "#",
            "User-Agent: *",
            "Allow: /$",
            "Allow: /home",
            "Allow: /about",
            "Allow: /collections",
            "Allow: /resources/*"
        ]

        #
        # Add public collections
        #
        collections = Admin::Project.where(:public => true)
        collections.each do |collection|
            if  collection.landing_page_slug &&
                !collection.landing_page_slug.blank?

                lines.push("Allow: /#{collection.landing_page_slug}")
            end
        end

        #
        # Disallow all else
        #
        lines.push("Disallow: /")

        render :text => lines.join("\n")
        return
    else

        render :file => 'public/robots.static.txt'
        return
    end
  end

end
