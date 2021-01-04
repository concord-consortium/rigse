class CreateNces06Indexes < ActiveRecord::Migration
  def self.up
    add_index     :portal_nces06_districts,   :LEAID      # NCES Local Education Agency ID.  The first two positions of this field are also the Federal Information Profesing Standards (FIPS) state code.
    add_index     :portal_nces06_districts,   :STID       # Stateís own ID for the education agency.
    add_index     :portal_nces06_districts,   :NAME       # Name of the education agency.

    add_index     :portal_nces06_schools,     :NCESSCH    # Unique NCES public school ID (7-digit NCES agency ID (LEAID) + 5-digit NCES school ID (SCHNO).
    add_index     :portal_nces06_schools,     :STID       # State's own ID for the education agency.
    add_index     :portal_nces06_schools,     :SCHNAM     # Name of the school.
  end

  def self.down
    remove_index  :portal_nces06_districts,   :LEAID      # NCES Local Education Agency ID.  The first two positions of this field are also the Federal Information Profesing Standards (FIPS) state code.
    remove_index  :portal_nces06_districts,   :STID       # Stateís own ID for the education agency.
    remove_index  :portal_nces06_districts,   :NAME       # Name of the education agency.

    remove_index  :portal_nces06_schools,     :NCESSCH    # Unique NCES public school ID (7-digit NCES agency ID (LEAID) + 5-digit NCES school ID (SCHNO).
    remove_index  :portal_nces06_schools,     :STID       # State's own ID for the education agency.
    remove_index  :portal_nces06_schools,     :SCHNAM     # Name of the school.
  end
end
