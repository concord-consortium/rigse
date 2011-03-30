module WorkgroupHelper
  def workgroup_javascript
    if APP_CONFIG[:use_adhoc_workgroups]
      return javascript_tag "document.observe('dom:loaded', function() { EnableWorkgroups();});"
    end
  end
end
