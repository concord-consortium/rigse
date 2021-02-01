PORTAL_COLUMNS_TO_SEARCH = {
  'ExternalActivity' => %w[url launch_url author_url print_url teacher_guide_url],
  'Admin::AuthoringSite' => ['url'],
  'Client' => ['site_url'],
  'LearnerProcessingEvent' =>  ['url']
}.freeze

# CollaborationRuns: collaborators_data_url
# InteractiveRunStates: learner_url
# PortalPublications: portal_url
# Runs: remote_endpoint, class_info_url
# SequenceRuns: remote_endpoint

LARA_COLUMNS_TO_SEARCH = {
  'CollaborationRun' => ['collaborators_data_url'],
  'InteractiveRunState' => ['learner_url'],
  'PortalPublication' => ['portal_url'],
  'Run' => %w[remote_endpoint class_info_url],
  'SequenceRun' =>  %w[remote_endpoint class_info_url]
}.freeze


def execute(sql)
  puts sql
  ActiveRecord::Base.connection.execute(sql)
end
# Other LARA columns that might be important: imported_activity_url in sequences

# This one only works for LARA:
def delete_unused_portal_publications(good_portal)
  sql = "DELETE FROM portal_publications WHERE portal_url NOT LIKE '%#{good_portal}%'"
  execute(sql)
end

def replace_server_in_table_column(clazz, column, old_name, new_name)
  table = clazz.table_name
  sql = "UPDATE #{table} SET #{column} = REPLACE(#{column}, '#{old_name}','#{new_name}')"
  execute(sql)
end

def print_values_in_table(clazz, column)
  puts clazz.pluck(column)
end

def update_server_name(column_hash, old_name, new_name)
  column_hash.each_key do |clazz_name|
    columns = column_hash[clazz_name]
    clazz = clazz_name.classify.constantize
    columns.each do |column|
      replace_server_in_table_column(clazz, column, old_name, new_name)
      # print_values_in_table(clazz, column)
    end
  end
end

# In the Portal: Update references to LARA
# update_server_name("authoring.concord.org", "lara-qa.concord-qa.org")
# https://lara-npaessel-qa.concordqa.org
# update_server_name(
#   PORTAL_COLUMNS_TO_SEARCH,
#   "lara-qa.concord-qa.org",
#   "lara-npaessel-qa.concordqa.org"
# )

# In the Portal: Update references to PORTAL from LARA
update_server_name(
  LARA_COLUMNS_TO_SEARCH,
  "ngss-assessment.portal.concord.org",
  "ngsa-npaessel.concordqa.org"
)

delete_unused_portal_publications("ngsa-npaessel.concordqa.org")
# One other thing we should do ** just to be on the safe side ** is delete portal
# publications where the the portal_url isn't the one we are paired with.
