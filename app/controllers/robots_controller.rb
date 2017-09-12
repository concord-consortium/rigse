class RobotsController < ApplicationController
  require 'nokogiri'

  layout false

  #
  # Generate a robots.txt file
  #
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

        #
        # Add sitemap
        #
        lines.push("Sitemap: #{APP_CONFIG[:site_url]}/sitemap.xml")

        render :text => lines.join("\n")
        return
    else

        render :file => 'public/robots.static.txt'
        return
    end
  end


  #
  # Generate a sitemap.xml file
  #
  def sitemap

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|

        xml.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9') {

            #
            # Add default top level pages
            #
            pages = ["", "home", "about", "collections"]
            pages.each do |page|
                xml.url {
                    xml.loc "#{APP_CONFIG[:site_url]}/#{page}"
                }
            end

            #
            # Add stem finder filter URLs
            #
            filters = {
                        "subject"       => [    "physics-chemistry",
                                                "life-sciences",
                                                "engineering-tech",
                                                "earth-space",
                                                "mathematics"       ],

                        "grade-level"   => [    "elementary-school",
                                                "middle-school",
                                                "high-school",
                                                "higher-education"  ]

                        }

            filters.each do |filter, values|
                values.each do |value|
                    xml.url {
                        xml.loc "#{APP_CONFIG[:site_url]}/resources/#{filter}/#{value}"
                    }
                end
            end

            #
            # Add activities, sequences and interactives.
            #
            materials =
                ExternalActivity.
                    includes([:cohorts, :cohort_items]).
                    where(:publication_status => "published") +
                Interactive.
                    includes([:cohorts, :cohort_items]).
                    where(:publication_status => "published")


            materials.each do |material|

                if ! policy(material).visible?
                    next
                end

                stem_resource_type = material.respond_to?(:lara_sequence?) ? 
                                        (material.lara_sequence? ? 
                                            'sequence' : 'activity') 
                                        : material.class.name.downcase

                slug = material.name.respond_to?(:parameterize) ? 
                        material.name.parameterize : nil

                xml.url {
                    xml.loc     "#{view_context.stem_resources_url(stem_resource_type, material.id, slug)}"
                    xml.lastmod "#{material.updated_at.strftime('%Y-%m-%d')}"
                }

            end 

            #
            # Add public collections
            #
            collections = Admin::Project.where(:public => true)
            collections.each do |collection|
                if  collection.landing_page_slug &&
                    !collection.landing_page_slug.blank?

                    xml.url {
                        xml.loc     "#{APP_CONFIG[:site_url]}/#{collection.landing_page_slug}"
                        xml.lastmod "#{collection.updated_at.strftime('%Y-%m-%d')}"
                    }

                end
            end

        }
    end

    render :xml => builder.to_xml

  end

end
