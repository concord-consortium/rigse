class AddResourceLicense < ActiveRecord::Migration
  def up
    add_column :external_activities, :license_code, :string
    add_column :interactives, :license_code, :string

    # clear existing unversioned licenses
    CommonsLicense.delete_all

    # load updated licenses with version numbers
    defs = YAML::load_file(File.join(Rails.root,"config","licenses.yml"));
    defs['licenses'].each do |license_hash|
      license = CommonsLicense.find_or_create_by_code(license_hash)
      license.update_attributes(license_hash)
      license.save
    end

    # make existing unversioned images commons licenses 3.0
    unversioned = ['CC-BY', 'CC-BY-SA', 'CC-BY-NC', 'CC-BY-NC-SA', 'CC-BY-ND', 'CC-BY-NC-ND']
    Image.find_all_by_license_code([unversioned]).each do |image|
      image.license_code = image.license_code + ' 3.0'
      image.save!
    end

    # make existing unlicensed resources 4.0
    ExternalActivity.update_all(:license_code => 'CC-BY 4.0')
    Interactive.update_all(:license_code => 'CC-BY 4.0')
  end

  def down
    remove_column :external_activities, :license_code
    remove_column :interactives, :license_code
  end
end
