#!/usr/bin/env ruby
#
STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

puts "\nFinding possible candidates for running in the browser...\n"

@activity_models = {}

def is_lw_possible?(activity)
  @activity_models[activity.id] ||= []
  activity.sections.each do |section|
    next unless section.is_enabled?
    section.pages.each do |page|
      next unless page.is_enabled?
      page.page_elements.each do |element|
        if element.is_enabled?
          component = element.embeddable
          case component
          when Embeddable::OpenResponse,Embeddable::MultipleChoice,Embeddable::Xhtml,Embeddable::Diy::Section
            # do nothing, these are OK
          when Embeddable::Diy::EmbeddedModel
            # if it's not MW, reject
            return false if component.diy_model.model_type_id != 1
            @activity_models[activity.id] << component.diy_model
          else
            # reject
            return false
          end
        end
      end
    end
  end
  return true
end

as = Activity.published_exemplars(:include => {:sections => {:pages => {:page_elements => {:embeddable => [:component]}}}})

candidates = as.select {|a| is_lw_possible?(a) }

File.open("candidates.md","w") do |file|
  candidates.sort_by{|a,b| [a.offerings.count, a.name]}.reverse.each do |a|
    file.write "[#{a.name}](http://itsisu.portal.concord.org/activities/#{a.id}) (used: #{a.offerings.count})\n"
    @activity_models[a.id].uniq.map{|m| [m.id, m.name]}.sort.each do |minfo|
      file.write "* [#{minfo[1]}](http://itsisu.portal.concord.org/diy/models/#{minfo[0]})\n"
    end
    file.write "\n"
  end
end