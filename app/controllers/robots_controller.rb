class RobotsController < ApplicationController
  
  layout false

  @@STEM_URLS = 
    {   "subject"       =>  {
                                "physics-chemistry" => {},
                                "life-sciences"     => {},
                                "engineering-tech"  => {},
                                "earth-space"       => {},
                                "mathematics"       => {}
                            },
        "grade-level"   =>  {
                                "elementary-school" => {},
                                "middle-school"     => {},
                                "high-school"       => {},
                                "higher-education"  => {}
                            } 
    } 

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
        ]

        #
        # Add stem finder URLs
        #
        @@STEM_URLS.each do |filter, values|
            values.each do |value, ignore|
                lines.push("Allow: /stem-resources/#{filter}/#{value}")
            end
        end
      
        #
        # Add public collections
        #
        collections = Admin::Project.where(:public => true)
        collections.each do |collection|
            lines.push("Allow: /#{collection.landing_page_slug}")
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
