# encoding: utf-8

require 'spec_helper'


describe Search do
  include SolrSpecHelper

  def make(let_expression); end # Syntax sugar for our lets

  def collection(factory, count=3, opts={})
    results = []
    count.times do
      yield opts if block_given?
      results << FactoryBot.create(factory.to_sym, opts)
    end
    results
  end

  describe "parameter cleaning" do
    describe "clean_search_terms" do
      it "should remove normal dashes" do
        expect(Search.clean_search_terms("balrgs-bonk")).to eq("balrgs bonk")
      end
      it "should remove pluses" do
        expect(Search.clean_search_terms("balrgs+bonk")).to eq("balrgs bonk")
      end
      it "should remove pluses" do
        expect(Search.clean_search_terms("balrgs+bonk")).to eq("balrgs bonk")
      end
      it "should leave white spaces in the middle" do
        expect(Search.clean_search_terms("balrgs bonk")).to eq("balrgs bonk")
      end
      it "should strip whitespace at the start" do
        expect(Search.clean_search_terms(" balrgs bonk")).to eq("balrgs bonk")
      end

      it "should not remove single quote strings" do
        expect(Search.clean_search_terms("This is Sarah's test sequence")).to eq("This is Sarah's test sequence")
      end

    end

    describe "clean_material_types(types)" do
      subject { Search.clean_material_types(types) }
      let(:types){nil}
      describe "when types is nil" do
        let(:types){nil}
        it "should return AllMaterials" do
          expect(subject).to eq(Search::AllMaterials)
        end
      end
      describe "when types is blank" do
        let(:types){""}
        it "should return AllMaterials" do
          expect(subject).to eq(Search::AllMaterials)
        end
      end
      describe "when types is empty" do
        let(:types){[]}
        it "should return AllMaterials" do
          expect(subject).to eq(Search::AllMaterials)
        end
      end
      describe "when types is a string" do
        let(:types){Search::InvestigationMaterial}
        it "should return an array" do
          expect(subject).to eq([Search::InvestigationMaterial])
        end
      end
      describe "when types is an array" do
        let(:types){[Search::InvestigationMaterial, Search::ActivityMaterial]}
        it "should return an array" do
          expect(subject).to eq([Search::InvestigationMaterial, Search::ActivityMaterial])
        end
      end
    end
  end

  describe "searching" do
    let(:user_stubs) {{ portal_teacher: nil, anonymous?: false, only_a_student?: false , has_role?: false}}
    let(:mock_user)  { mock_model(User, user_stubs) }
    let(:materials)  { [] }
    before(:all) do
      solr_setup
      clean_solar_index
    end

    before(:each) do
      make materials
      reindex_all
    end

    after(:each) do
      clean_solar_index
    end

    let(:official)       {{ :is_official => true               }}
    let(:public_opts)    {{ :publication_status => "published" }}
    let(:private_opts)   {{ :publication_status => "private"   }}
    let(:external_base)  {{ :url => 'http://activities.com'    }}
    let(:assessment_opts){{
      :is_assessment_item => true, :publication_status => "published"
    }}

    let(:external_seq) { external_base.merge({ material_type: "Investigation" }) }
    let(:external_act) { external_base.merge({ material_type: "Activity" }) }

    let(:public_ext_act)        { collection(:external_activity, 2, external_act.merge(public_opts).merge(official))  }
    let(:private_ext_act)       { collection(:external_activity, 2, external_act.merge(private_opts).merge(official)) }
    let(:public_ext_seq)        { collection(:external_activity, 2, external_seq.merge(public_opts).merge(official))  }
    let(:private_ext_seq)       { collection(:external_activity, 2, external_seq.merge(private_opts).merge(official)) }
    let(:assessment_activities) { collection(:external_activity, 2, assessment_opts) }
    let(:search_opts) { {} }

    subject do
      s = Search.new(search_opts)
    end

    context "with existing collections" do
      let(:private_items) { [private_ext_act, private_ext_seq].flatten}
      let(:public_items)  { [public_ext_act,  public_ext_seq].flatten}
      let(:materials)     { [public_items, private_items].flatten }

      describe "searching for materials with tricky names" do
        let(:funny_name)       { "" }
        let(:funny_activity)   { FactoryBot.create(:external_activity, public_opts.merge(:name=>funny_name)) }
        let(:search_opts)      { {:search_term => search_term} }
        let(:search_term)      { "" }
        let(:materials)        { [funny_activity] }
        describe "an activity named '(2013-2014) soup'" do
          let(:funny_name) {"( 2013 - 2014 ) soup"}
          describe "searching for '2013'" do
            let(:search_term)      { "2013" }
            it "should be found" do
              expect(subject.results[:all]).to include funny_activity
            end
          end
          describe "searching for '(2013-2014)'" do
            let(:search_term)      { "(2013-2014)" }
            it "should be found" do
              expect(subject.results[:all]).to include funny_activity
            end
          end
          describe "searching for 'BLARG' " do
            let(:search_term)      { "BLARG" }
            it "should NOT be found" do
              expect(subject.results[:all]).not_to include funny_activity
            end
          end
        end
        describe "Noah's soup'" do
          let(:funny_name) {"Noah's soup"}
          describe "searching for 'Noah's'" do
            let(:search_term)      { "Noah's" }
            it "should be found" do
              expect(subject.results[:all]).to include funny_activity
            end
          end
          describe "searching for 'Noah'" do
            let(:search_term)      { "Noah*" }
            it "should be found" do
              expect(subject.results[:all]).to include funny_activity
            end
          end
          describe "searching for 'Soup'" do
            let(:search_term)      { "Soup" }
            it "should be found" do
              expect(subject.results[:all]).to include funny_activity
            end
          end
        end
      end

      describe "searching collections that includes assessment items" do
        let(:materials)     { [public_items, assessment_activities].flatten }
        let(:search_opts)   {{ :user_id => mock_user.id }}
        before(:each) do
          allow(User).to receive_messages(:find => mock_user)
        end
        describe "a teacher" do
          let(:user_stubs) {{
            anonymous?: false,
            portal_teacher: mock_model(Portal::Teacher, {cohorts: []}),
            only_a_student?: false,
            has_role?: false
          }}

          it "should see the assessment items" do
            assessment_activities.each do |act|
              expect(subject.results[:all]).to include act
            end
          end
        end

        describe "a student" do
          let(:user_stubs) {{
            anonymous?: false,
            portal_teacher: nil,
            only_a_student?: true,
            has_role?: false
          }}
          it "should not see the assessment items" do
            assessment_activities.each do |act|
              expect(subject.results[:all]).not_to include act
            end
          end
        end

        describe "an anonymous user" do
          let(:user_stubs) {{
            anonymous?: true,
            portal_teacher: nil,
            has_role?: false
          }}
          it "should not see the assment items" do
            assessment_activities.each do |act|
              expect(subject.results[:all]).not_to include act
            end
          end

        end

      end

      describe "searching public items" do
        let(:search_opts) { {:private => false } }
        it "results should include 4 public external_activities" do
          expect(subject.results[:all].entries.size).to eq(4)
          # Sequence externals
          expect(subject.results[Search::InvestigationMaterial].entries.size).to eq(2)
          # Actvitiy externals
          expect(subject.results[Search::ActivityMaterial].entries.size).to eq(2)
        end
      end

      describe "behavior of archived materials" do
        let(:published_opts)      { external_act.merge({ publication_status: "published" })}
        let(:archived_opts)       { published_opts.merge({is_archived: true })}
        let(:unarchived_opts)     { published_opts.merge({is_archived: false })}
        let(:archived_activity)   { FactoryBot.create(:external_activity, archived_opts) }
        let(:unarchived_activity) { FactoryBot.create(:external_activity, unarchived_opts) }
        let(:materials) { [archived_activity, unarchived_activity] }
        describe "with default search options" do
          it "results should include not include archived activities" do
            expect(subject.results[:all].entries.size).to eq(1)
            expect(subject.results[:all]).to include(unarchived_activity)
          end
        end
        describe "when searching for archived items" do
          let(:search_opts) { {:show_archived => true } }
          it "results should include only archived activities" do
            # TBD: I think we decided to only show archived with this option
            expect(subject.results[:all].entries.size).to eq(1)
            expect(subject.results[:all]).to include(archived_activity)
          end
        end
      end

      describe "searching all items" do
        let(:search_opts) { {:private => true, :include_templates => true} }
        it "results should include 4 external activities and 4 external sequences" do
          expect(subject.results[Search::InvestigationMaterial].entries.size).to eq(4)
          expect(subject.results[Search::ActivityMaterial].entries.size).to eq(4)
        end
      end

      describe "searching only public Sequences" do
        let(:search_opts) { {:private  => false, :material_types => ["Investigation"]} }
        it "results should include 4 investigations" do
          expect(subject.results[:all].entries.size).to eq(2)
          expect(subject.results[Search::InvestigationMaterial].entries.size).to eq(2)
        end
      end

      describe "external activities binning by sequence or activity" do
        let(:factory_opts)     {{:publication_status => "published"}     }
        let(:external_activity){FactoryBot.create(:external_activity)}
        let(:materials) do
            [
              collection(:external_activity, 2, factory_opts),
              external_activity
            ].flatten
          end

        describe "When the template type is an Activity" do

          describe "when its an offical activity" do
            let(:external_activity){FactoryBot.create(:external_activity, external_act.merge(public_opts).merge(official))}
            it "should be listed in the activity results" do
              expect(subject.results[Search::InvestigationMaterial]).not_to include(external_activity)
              expect(subject.results[Search::ActivityMaterial]).to include(external_activity)
            end
          end

          describe "when its a contributed activity" do
            let(:external_activity){FactoryBot.create(:external_activity, external_act.merge(public_opts))}
            describe "when the search doesn't include contributed items" do
              let(:search_opts) { {:include_official => true } }
              it "should not be listed in the results" do
                expect(subject.results[Search::InvestigationMaterial]).not_to include(external_activity)
                expect(subject.results[Search::ActivityMaterial]).not_to include(external_activity)
              end
            end

            describe "when the search includes contributed items" do
              let(:search_opts) { {:include_contributed => true } }
              it "should not be listed in the activity results" do
                expect(subject.results[Search::InvestigationMaterial]).not_to include(external_activity)
                expect(subject.results[Search::ActivityMaterial]).to include(external_activity)
              end
            end
          end

        end

        describe "When there is no template" do
          let(:external_activity){FactoryBot.create(:external_activity, external_base.merge(public_opts).merge(official).merge({:material_type => 'Activity'}))}
          it "should be listed in the Activity results" do
            expect(subject.results[Search::InvestigationMaterial]).not_to include(external_activity)
            expect(subject.results[Search::ActivityMaterial]).to include(external_activity)
          end
        end
      end

      describe "searching with user_id" do
        let(:my_id)          { 23 }
        let(:my_activity)    { FactoryBot.create(:external_activity, {:publication_status => "private", :user_id => my_id })}
        let(:someone_elses)  { FactoryBot.create(:external_activity, {:publication_status => "private", :user_id => 777   })}
        let(:private_items)  { [my_activity,someone_elses]}
        let(:public_items)   { collection(:external_activity, 2, public_opts)}
        let(:search_opts)     {{ :private => false, :user_id => my_id }}
        before(:each) do
          allow(User).to receive_messages(:find => mock_user)
        end
        it "should return public items" do
          public_items.each do |act|
            expect(subject.results[Search::ActivityMaterial]).to include(act)
          end
        end

        it "should return the my_activity" do
          expect(subject.results[Search::ActivityMaterial]).to include(my_activity)
          # subject.results[:users].should include(my_activity)
        end
      end


      describe "With cohort tags" do
        let(:teacher_cohorts) {[]}
        let(:teacher)    {
          mock_model(Portal::Teacher, :cohorts => teacher_cohorts)
        }
        let(:user_stubs) {{
          portal_teacher: teacher,
          only_a_student?: false,
          anonymous?: false,
          has_role?: false,
          id: 23
        }}
        let(:search_opts){{ :private => false, :user_id => mock_user.id }}
        before(:each) do
          allow(User).to receive_messages(:find => mock_user)
        end
        describe "With two defined cohorts"  do
          describe "With activities in every combination of cohorts " do
            let(:cohort1) { FactoryBot.create(:admin_cohort, name: 'cohort1') }
            let(:cohort2) { FactoryBot.create(:admin_cohort, name: 'cohort2') }

            let(:cohort1_opts) {{:publication_status=>'published', :cohorts => [cohort1] }}
            let(:cohort2_opts) {{:publication_status=>'published', :cohorts => [cohort2] }}
            let(:both_opts)    {{:publication_status=>'published', :cohorts => [cohort1, cohort2] }}

            let(:blank_sequence)     { collection(:external_activity, 1, external_seq.merge( public_opts)) }
            let(:cohort1_sequences)  { collection(:external_activity, 2, external_seq.merge(cohort1_opts))}
            let(:cohort2_sequences)  { collection(:external_activity, 2, external_seq.merge(cohort2_opts))}
            let(:both_sequences)     { collection(:external_activity, 1, external_seq.merge(both_opts))}

            let(:blank_activity)     { collection(:external_activity, 1, public_opts) }
            let(:cohort1_activities) { collection(:external_activity, 2, cohort1_opts)}
            let(:cohort2_activities) { collection(:external_activity, 2, cohort2_opts)}
            let(:both_activity)      { collection(:external_activity, 1, both_opts)}

            let(:blank_external)     { collection(:external_activity, 1, external_base.merge(official).merge(public_opts).merge({:material_type => 'Activity'}) ) }
            let(:cohort1_externals)  { collection(:external_activity, 2, external_base.merge(official).merge(cohort1_opts).merge({:material_type => 'Activity'})) }
            let(:cohort2_externals)  { collection(:external_activity, 2, external_base.merge(official).merge(cohort2_opts).merge({:material_type => 'Activity'})) }

            let(:materials) do
              [
                blank_sequence, blank_activity, blank_external,
                cohort1_sequences, cohort1_activities, cohort1_externals,
                cohort2_sequences, cohort2_activities, cohort2_externals,
                both_sequences, both_activity
              ].flatten
            end

            describe "not a teacher" do
              let(:teacher) { nil }

              describe "Searching all material types" do

                it "Includes all only blank sequences" do
                  expect(subject.results[Search::InvestigationMaterial].size).to eq(1)
                end
                it "Includes blank activities and blank externals" do
                  expect(subject.results[Search::ActivityMaterial].size).to eq(2)
                end
              end
            end

            describe "not in a cohort" do
              let(:teacher_cohorts) { [] }

              describe "Searching all material types" do

                it "Includes all only blank sequences" do
                  expect(subject.results[Search::InvestigationMaterial].size).to eq(1)
                end
                it "Includes blank activities and blank externals" do
                  expect(subject.results[Search::ActivityMaterial].size).to eq(2)
                end
              end
            end

            describe "Teacher in Cohort1" do
              let(:teacher_cohorts) { [cohort1] }

              describe "Searching all material types" do

                it "Includes sequences for cohort1(2), both(1), and unlabled(2)" do
                  expect(subject.results[Search::InvestigationMaterial].size).to eq(4)
                end
                it "Includes activities for cohort1(4), both(1), and unlabled(2)" do
                  expect(subject.results[Search::ActivityMaterial].size).to eq(7)
                end
                it "should be not cohort tagged, or include a cohort1 tag" do
                  subject.results[:all].each do |r|
                    unless r.cohorts.empty?
                      expect(r.cohorts).to include(cohort1)
                    end
                  end
                end
              end
            end

            describe "Teacher in Cohort2" do
              let(:teacher_cohorts) { [cohort2] }

              describe "Searching all material types" do

              it "Includes sequences for cohort2(2), both(1), and unlabled(2)" do
                  expect(subject.results[Search::InvestigationMaterial].size).to eq(4)
                end
                it "Includes activities for cohort2(4), both(1), and unlabled(2)" do
                  expect(subject.results[Search::ActivityMaterial].size).to eq(7)
                end
                it "should be not cohort tagged, or include a cohort2 tag" do
                  subject.results[:all].each do |r|
                    unless r.cohorts.empty?
                      expect(r.cohorts).to include(cohort2)
                    end
                  end
                end
              end
            end

            describe "Teacher in both cohorts" do
              let(:teacher_cohorts) { [cohort2, cohort1] }

              describe "Searching all material types" do

                it "Includes sequences for cohort1(2) cohort2(2), and unlabled(2)" do
                  expect(subject.results[Search::InvestigationMaterial].size).to eq(6)
                end
                it "Includes activities for cohort2(4), cohort1(4), and unlabled(2)" do
                  expect(subject.results[Search::ActivityMaterial].size).to eq(10)
                end
              end
            end

            describe "The teacher is the author of cohort2 activities, but isnt in either cohort" do
              let(:teacher_cohorts)    {[]}
              let(:cohort2_opts) {{:publication_status=>'published', :cohorts => [cohort2], :user_id => mock_user.id} }

              it "Includes sequences for cohort2(2), and unlabled(2)" do
                expect(subject.results[Search::InvestigationMaterial].size).to eq(3)
              end
              it "Includes activities for cohort2(4), and unlabled(2)" do
                expect(subject.results[Search::ActivityMaterial].size).to eq(6)
              end
              it "should be not cohort tagged, or include a cohort2 tag" do
                subject.results[:all].each do |r|
                  unless r.cohorts.empty?
                    expect(r.cohorts).to include(cohort2)
                  end
                end
              end

            end

            describe "The current visitor is a site admin, not in either cohort" do
              let(:user_stubs) {{
                  portal_teacher: nil,
                  anonymous?: false,
                  only_a_student?: false,
                  has_role?: true }}
              describe "Searching all material types" do
                it "Includes sequences for cohort1(2) cohort2(2), and unlabled(2)" do
                  expect(subject.results[Search::InvestigationMaterial].size).to eq(6)
                end
                it "Includes activities for cohort2(4), cohort1(4), and unlabled(2)" do
                  expect(subject.results[Search::ActivityMaterial].size).to eq(10)
                end
              end
            end

          end
        end
      end

      describe "with projects" do
        let(:public_projects) { collection(:project, 2) }

        describe "available_projects" do
          subject { Search.new(search_opts).available_projects }

          describe "when public external activities have public projects" do
            before(:each) do
              # add these projects to a public external activity
              public_ext_act.first.projects = public_projects
              reindex_all
            end

            it "should contain both public projects" do
              expect(subject[0][:id]).to eql public_projects[0].id
              expect(subject[1][:id]).to eql public_projects[1].id
            end
          end
        end
      end


      describe "ordering" do
        describe "by date" do
          let(:search_opts) { {:private => false, :sort => Search::Newest} }
          let(:factory_opts){ {:publication_status => "published"}         }
          let(:materials) do
            [
              collection_with_rand_mod_time(:external_activity, 6, factory_opts),
              collection_with_rand_mod_time(:external_activity, 6, factory_opts)
            ].flatten
          end

          describe "Search::Newest" do
            it "the collection should be sorted by updated_at newest ➙ oldest" do
              expect(subject.results[Search::InvestigationMaterial]).to be_ordered_by(:updated_at_desc)
              expect(subject.results[Search::ActivityMaterial]).to be_ordered_by(:updated_at_desc)
            end
          end

          describe "Search::Oldest" do
            let(:search_opts) { {:private => false, :sort_order => Search::Oldest} }
            it "the collection should be sorted by updated_at oldest ➙ newest" do
              expect(subject.results[Search::InvestigationMaterial]).to be_ordered_by(:updated_at)
              expect(subject.results[Search::ActivityMaterial]).to be_ordered_by(:updated_at)
            end
          end
        end # by date

        describe "by Popularity" do
          let(:search_opts) { {:private => false, :sort_order => Search::Popularity} }
          let(:factory_opts){ {:publication_status => "published"}         }
          let(:materials) do
            [
              collection(:external_activity, 5, factory_opts) do |o|
                o[:offerings_count] = rand(0..10)
              end,
              collection(:external_activity, 5, external_seq.merge(public_opts)) do |o|
                o[:offerings_count] = rand(0..10)
              end,
              collection(:external_activity, 3, factory_opts) do |o|
                o[:offerings_count] = rand(0..10)
              end,
              collection(:external_activity, 3, external_act.merge(public_opts)) do |o|
                o[:offerings_count] = rand(0..10)
              end
            ].flatten
          end
          it "the collection should be sotred by offerings_count desc" do
            expect(subject.results[Search::InvestigationMaterial]).to be_ordered_by(:offerings_count_desc)
            expect(subject.results[Search::ActivityMaterial]).to be_ordered_by(:offerings_count_desc)
          end
        end
      end
    end

    context "with sensor tags" do
      let(:public_with_temperature_sensor) {
        FactoryBot.create(:external_activity, :url => 'http://activities.com',
          :is_official => true, :publication_status => "published",
          :sensor_list => ['Temperature']
        )
      }
      let(:public_with_force_sensor) {
        FactoryBot.create(:external_activity, :url => 'http://activities.com',
          :is_official => true, :publication_status => "published",
          :sensor_list => ['Force']
        )
      }
      let(:public_with_force_and_temperature_sensor) {
        FactoryBot.create(:external_activity, :url => 'http://activities.com',
          :is_official => true, :publication_status => "published",
          :sensor_list => ['Force', 'Temperature']
        )
      }
      let(:materials) { [public_with_temperature_sensor, public_with_force_sensor,
        public_with_force_and_temperature_sensor, public_ext_act]}
      it "the temperature activity is returned" do
        expect(subject.results[:all]).to include(public_with_temperature_sensor)
      end
      describe "with the temperature sensor selected" do
        let(:search_opts)      { {:sensors => ["Temperature"]} }
        it "only returns activities with a temperature sensor" do
          expect(subject.results[:all].entries.size).to eq(2)
          expect(subject.results[:all]).to include(public_with_temperature_sensor)
          expect(subject.results[:all]).to include(public_with_force_and_temperature_sensor)
        end
      end
      describe "with the 'no sensors' option selected" do
        let(:search_opts)      { {:no_sensors => true} }
        it "only returns activities without sensors" do
          # public_ext_act is an array so we need to turn it into set parameters
          expect(subject.results[:all]).to include(*public_ext_act)
          expect(subject.results[:all]).not_to include(public_with_temperature_sensor)
          expect(subject.results[:all]).not_to include(public_with_force_sensor)
          expect(subject.results[:all]).not_to include(public_with_force_and_temperature_sensor)
        end
      end
      describe "with the 'no sensors' option selected and temperature sensor selected" do
        let(:search_opts)      { {:no_sensors => true, :sensors => ["Temperature"]} }
        it "returns activities with no sensors and with temperature sensors" do
          # public_ext_act is an array so we need to turn it into set parameters
          expect(subject.results[:all]).to include(*public_ext_act)
          expect(subject.results[:all]).to include(public_with_temperature_sensor)
          expect(subject.results[:all]).to include(public_with_force_and_temperature_sensor)
          expect(subject.results[:all]).not_to include(public_with_force_sensor)
        end
      end
    end

    context "for projects" do
      # create projects
      let(:foo_project) {
        FactoryBot.create(:project, name: "Foo", landing_page_slug: "first-project", public: true,
          landing_page_content: "The foo project has content about cats",
          project_card_description: "This is the description about felines",
          grade_level_list: ["1", "2"], subject_area_list: ["Math"]
        )
      }
      let(:bar_project) {
        FactoryBot.create(:project, name: "Bar", landing_page_slug: "second-project", public: true,
          landing_page_content: "The bar project also has content about cats",
          project_card_description: "This is also the description about felines",
          grade_level_list: ["1", "3"], subject_area_list: ["Math", "Chemistry"]
        )
      }
      let(:baz_project) {
        FactoryBot.create(:project, name: "Baz", landing_page_slug: "third-project", public: false,
          landing_page_content: "The baz project is private and should not show in search results",
          project_card_description: "This is the description about private projects",
          grade_level_list: ["1", "2"], subject_area_list: ["Math"]
        )
      }
      let(:search_opts) { { :search_projects => true } }

      before(:each) do
        foo_project
        bar_project
        baz_project
        Admin::Project.reindex
        Sunspot.commit
      end

      describe "with no options" do
        it "returns in alphabetical name order filtering out private projects" do
          expect(subject.results[:project].length).to eq(2)
          expect(subject.results[:project][0].public).to be(true)
          expect(subject.results[:project][1].public).to be(true)

          expect(subject.results[:project][0].id).to be(bar_project.id)
          expect(subject.results[:project][1].id).to be(foo_project.id)
        end
      end

      describe "by name" do
        let(:search_opts) { {:search_projects => true, :search_term => "foo"} }

        it "results in 1 result" do
          expect(subject.results[:project].length).to eq(1)
          expect(subject.results[:project][0].id).to be(foo_project.id)
        end
      end

      describe "by landing page content" do
        let(:search_opts) { {:search_projects => true, :search_term => "cats"} }

        it "results in 2 results" do
          expect(subject.results[:project].length).to eq(2)

          expect(subject.results[:project][0].id).to be(bar_project.id)
          expect(subject.results[:project][1].id).to be(foo_project.id)
        end
      end

      describe "by project card description" do
        let(:search_opts) { {:search_projects => true, :search_term => "felines"} }

        it "results in 2 results" do
          expect(subject.results[:project].length).to eq(2)

          expect(subject.results[:project][0].id).to be(bar_project.id)
          expect(subject.results[:project][1].id).to be(foo_project.id)
        end
      end

      describe "by landing page slug" do
        let(:search_opts) { {:search_projects => true, :search_term => "second"} }

        it "results in 1 result" do
          expect(subject.results[:project].length).to eq(1)
          expect(subject.results[:project][0].id).to be(bar_project.id)
        end
      end

      describe "by grade levels" do
        let(:search_opts) { {:search_projects => true, :grade_level_groups => ["3-4"]} }

        it "results in 1 results" do
          expect(subject.results[:project].length).to eq(1)
          expect(subject.results[:project][0].id).to be(bar_project.id)
        end
      end

      describe "by subject areas" do
        let(:search_opts) { {:search_projects => true, :subject_areas => ["Chemistry"]} }

        it "results in 1 results" do
          expect(subject.results[:project].length).to eq(1)
          expect(subject.results[:project][0].id).to be(bar_project.id)
        end
      end
    end
  end
end
