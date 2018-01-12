# encoding: utf-8

require 'spec_helper'


describe Search do
  include SolrSpecHelper

  def make(let_expression); end # Syntax sugar for our lets

  def collection(factory, count=3, opts={})
    results = []
    count.times do
      yield opts if block_given?
      results << FactoryGirl.create(factory.to_sym, opts)
    end
    results
  end

  describe "parameter cleaning" do
    describe "clean_search_terms" do
      it "should remove normal dashes" do
        Search.clean_search_terms("balrgs-bonk").should == "balrgs bonk"
      end
      it "should remove pluses" do
        Search.clean_search_terms("balrgs+bonk").should == "balrgs bonk"
      end
      it "should remove pluses" do
        Search.clean_search_terms("balrgs+bonk").should == "balrgs bonk"
      end
      it "should leave white spaces in the middle" do
        Search.clean_search_terms("balrgs bonk").should == "balrgs bonk"
      end
      it "should strip whitespace at the start" do
        Search.clean_search_terms(" balrgs bonk").should == "balrgs bonk"
      end

      it "should not remove single quote strings" do
        Search.clean_search_terms("This is Sarah's test sequence").should == "This is Sarah's test sequence"
      end

    end

    describe "clean_domain_id" do
      it "returns the defaults when passed nil" do
        Search.clean_domain_id(nil).should == Search::NoDomainID
      end
      it "wraps bare strings in an array" do
        Search.clean_domain_id("1").should == ["1"]
      end

      it "leaves arrays alone" do
        Search.clean_domain_id([1,2,3]).should == [1,2,3]
      end
    end

    describe "clean_material_types(types)" do
      subject { Search.clean_material_types(types) }
      let(:types){nil}
      describe "when types is nil" do
        let(:types){nil}
        it "should return AllMaterials" do
          subject.should == Search::AllMaterials
        end
      end
      describe "when types is blank" do
        let(:types){""}
        it "should return AllMaterials" do
          subject.should == Search::AllMaterials
        end
      end
      describe "when types is empty" do
        let(:types){[]}
        it "should return AllMaterials" do
          subject.should == Search::AllMaterials
        end
      end
      describe "when types is a string" do
        let(:types){Search::InvestigationMaterial}
        it "should return an array" do
          subject.should == [Search::InvestigationMaterial]
        end
      end
      describe "when types is an array" do
        let(:types){[Search::InvestigationMaterial, Search::ActivityMaterial]}
        it "should return an array" do
          subject.should == [Search::InvestigationMaterial, Search::ActivityMaterial]
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

    let(:external_seq) { external_base.merge({ :template => private_investigations.first})}
    let(:external_act) { external_base.merge({ :template => private_activities.first})}

    let(:public_investigations) { collection(:investigation, 2, public_opts) }
    let(:private_investigations){ collection(:investigation, 2, private_opts)}
    let(:public_activities)     { collection(:activity, 2, public_opts)      }
    let(:private_activities)    { collection(:activity, 2, private_opts)     }
    let(:public_ext_act)        { collection(:external_activity, 2, external_act.merge(public_opts).merge(official))  }
    let(:private_ext_act)       { collection(:external_activity, 2, external_act.merge(private_opts).merge(official)) }
    let(:public_ext_seq)        { collection(:external_activity, 2, external_seq.merge(public_opts).merge(official))  }
    let(:private_ext_seq)       { collection(:external_activity, 2, external_seq.merge(private_opts).merge(official)) }
    let(:assessment_activities) { collection(:activity, 2, assessment_opts) }
    let(:search_opts) { {} }

    subject do
      s = Search.new(search_opts)
    end

    context "with existing collections" do
      let(:private_items) { [private_investigations, private_activities, private_ext_act, private_ext_seq].flatten}
      let(:public_items)  { [public_investigations,  public_activities, public_ext_act,  public_ext_seq].flatten}
      let(:materials)     { [public_items, private_items].flatten }

      describe "searching for materials with tricky names" do
        let(:funny_name)       { "" }
        let(:funny_activity)   { FactoryGirl.create(:activity, public_opts.merge(:name=>funny_name)) }
        let(:search_opts)      { {:search_term => search_term} }
        let(:search_term)      { "" }
        let(:materials)        { [funny_activity] }
        describe "an activity named '(2013-2014) soup'" do
          let(:funny_name) {"( 2013 - 2014 ) soup"}
          describe "searching for '2013'" do
            let(:search_term)      { "2013" }
            it "should be found" do
              subject.results[:all].should include funny_activity
            end
          end
          describe "searching for '(2013-2014)'" do
            let(:search_term)      { "(2013-2014)" }
            it "should be found" do
              subject.results[:all].should include funny_activity
            end
          end
          describe "searching for 'BLARG' " do
            let(:search_term)      { "BLARG" }
            it "should NOT be found" do
              subject.results[:all].should_not include funny_activity
            end
          end
        end
        describe "Noah's soup'" do
          let(:funny_name) {"Noah's soup"}
          describe "searching for 'Noah's'" do
            let(:search_term)      { "Noah's" }
            it "should be found" do
              subject.results[:all].should include funny_activity
            end
          end
          describe "searching for 'Noah'" do
            let(:search_term)      { "Noah*" }
            it "should be found" do
              subject.results[:all].should include funny_activity
            end
          end
          describe "searching for 'Soup'" do
            let(:search_term)      { "Soup" }
            it "should be found" do
              subject.results[:all].should include funny_activity
            end
          end
        end
      end

      describe "searching collections that includes assessment items" do
        let(:materials)     { [public_items, assessment_activities].flatten }
        let(:search_opts)   {{ :user_id => mock_user.id }}
        before(:each) do
          User.stub!(:find => mock_user)
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
              subject.results[:all].should include act
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
              subject.results[:all].should_not include act
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
              subject.results[:all].should_not include act
            end
          end

        end

      end
      describe "template items should not be included in results by default" do
        let(:template_ivs)  { collection(:investigation_template, 2, public_opts) }
        let(:template_acts) { collection(:activity_template, 2, public_opts) }
        let(:materials)     { [public_items, template_ivs, template_acts].flatten }
        it "results should not include any of the template activities" do
          template_acts.each do |act|
            subject.results[:all].should_not include act
          end
        end

        it "results should not include any of the template investigations" do
          template_ivs.each do |inv|
            subject.results[:all].should_not include inv
          end
        end
      end

      describe "searching public items" do
        let(:search_opts) { {:private => false } }
        it "results should include 4 public activities and 4 public investigations" do
          subject.results[:all].should have(8).entries
          subject.results[Search::InvestigationMaterial].should have(4).entries
          subject.results[Search::ActivityMaterial].should have(4).entries
        end
      end

      describe "behavior of archived materials" do
        let(:published_opts)      { external_act.merge({ publication_status: "published" })}
        let(:archived_opts)       { published_opts.merge({is_archived: true })}
        let(:unarchived_opts)     { published_opts.merge({is_archived: false })}
        let(:archived_activity)   { FactoryGirl.create(:external_activity, archived_opts) }
        let(:unarchived_activity) { FactoryGirl.create(:external_activity, unarchived_opts) }
        let(:materials) { [archived_activity, unarchived_activity] }
        describe "with default search options" do
          it "results should include not include archived activities" do
            subject.results[:all].should have(1).entries
            subject.results[:all].should include(unarchived_activity)
          end
        end
        describe "when searching for archived items" do
          let(:search_opts) { {:show_archived => true } }
          it "results should include only archived activities" do
            # TBD: I think we decided to only show archived with this option
            subject.results[:all].should have(1).entries
            subject.results[:all].should include(archived_activity)
          end
        end
      end

      describe "searching all items" do
        let(:search_opts) { {:private => true, :include_templates => true} }
        it "results should include 8 activities and 8 investigations" do
          # subject.results[:all].should have(16).entries
          subject.results[Search::InvestigationMaterial].should have(8).entries
          subject.results[Search::ActivityMaterial].should have(8).entries
        end
      end

      describe "searching only public Investigations" do
        let(:search_opts) { {:private  => false, :material_types => ["Investigation"]} }
        it "results should include 4 investigations" do
          subject.results[:all].should have(4).entries
          subject.results[Search::InvestigationMaterial].should have(4).entries
        end
      end

      describe "external activities binning by sequence or activity" do
        let(:factory_opts)     {{:publication_status => "published"}     }
        let(:external_activity){FactoryGirl.create(:external_activity)}
        let(:materials) do
            [
              collection(:investigation, 2, factory_opts),
              collection(:activity, 2, factory_opts),
              external_activity
            ].flatten
          end

        describe "when the template type is an Investigation" do
          let(:external_activity){FactoryGirl.create(:external_activity, external_seq.merge(public_opts).merge(official))}
          it "should be listed in the investigations results" do
            subject.results[Search::InvestigationMaterial].should include(external_activity)
            subject.results[Search::ActivityMaterial].should_not include(external_activity)

          end
        end

        describe "When the template type is an Activity" do

          describe "when its an offical activity" do
            let(:external_activity){FactoryGirl.create(:external_activity, external_act.merge(public_opts).merge(official))}
            it "should be listed in the activity results" do
              subject.results[Search::InvestigationMaterial].should_not include(external_activity)
              subject.results[Search::ActivityMaterial].should include(external_activity)
            end
          end

          describe "when its a contributed activity" do
            let(:external_activity){FactoryGirl.create(:external_activity, external_act.merge(public_opts))}
            describe "when the search doesn't include contributed items" do
              let(:search_opts) { {:include_official => true } }
              it "should not be listed in the results" do
                subject.results[Search::InvestigationMaterial].should_not include(external_activity)
                subject.results[Search::ActivityMaterial].should_not include(external_activity)
              end
            end

            describe "when the search includes contributed items" do
              let(:search_opts) { {:include_contributed => true } }
              it "should not be listed in the activity results" do
                subject.results[Search::InvestigationMaterial].should_not include(external_activity)
                subject.results[Search::ActivityMaterial].should include(external_activity)
              end
            end
          end

        end

        describe "When there is no template" do
          let(:external_activity){FactoryGirl.create(:external_activity, external_base.merge(public_opts).merge(official).merge({:material_type => 'Activity'}))}
          it "should be listed in the Activity results" do
            subject.results[Search::InvestigationMaterial].should_not include(external_activity)
            subject.results[Search::ActivityMaterial].should include(external_activity)
          end
        end
      end

      describe "searching with user_id" do
        let(:my_id)          { 23 }
        let(:my_activity)    { FactoryGirl.create(:activity, {:publication_status => "private", :user_id => my_id })}
        let(:someone_elses)  { FactoryGirl.create(:activity, {:publication_status => "private", :user_id => 777   })}
        let(:private_items)  { [my_activity,someone_elses]}
        let(:public_items)   { collection(:activity, 2, public_opts)}
        let(:search_opts)     {{ :private => false, :user_id => my_id }}
        before(:each) do
          User.stub!(:find => mock_user)
        end
        it "should return public items" do
          public_items.each do |act|
            subject.results[Search::ActivityMaterial].should include(act)
          end
        end

        it "should return the my_activity" do
          subject.results[Search::ActivityMaterial].should include(my_activity)
          # subject.results[:users].should include(my_activity)
        end
      end


      describe "With cohort tags" do
        # TODO: COHORT FIXME
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
          User.stub!(:find => mock_user)
        end
        describe "With two defined cohorts"  do
          describe "With activities in every combination of cohorts " do
            let(:cohort1) { FactoryGirl.create(:admin_cohort, name: 'cohort1') }
            let(:cohort2) { FactoryGirl.create(:admin_cohort, name: 'cohort2') }

            let(:cohort1_opts) {{:publication_status=>'published', :cohorts => [cohort1] }}
            let(:cohort2_opts) {{:publication_status=>'published', :cohorts => [cohort2] }}
            let(:both_opts)    {{:publication_status=>'published', :cohorts => [cohort1, cohort2] }}

            let(:blank_sequence)     { collection(:investigation, 1, public_opts) }
            let(:cohort1_sequences)  { collection(:investigation, 2, cohort1_opts)}
            let(:cohort2_sequences)  { collection(:investigation, 2, cohort2_opts)}
            let(:both_sequences)     { collection(:investigation, 1, both_opts)}

            let(:blank_activity)     { collection(:activity, 1, public_opts) }
            let(:cohort1_activities) { collection(:activity, 2, cohort1_opts)}
            let(:cohort2_activities) { collection(:activity, 2, cohort2_opts)}
            let(:both_activity)      { collection(:activity, 1, both_opts)}

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
                  subject.results[Search::InvestigationMaterial].should have(1).items
                end
                it "Includes blank activities and blank externals" do
                  subject.results[Search::ActivityMaterial].should have(2).items
                end
              end
            end

            describe "not in a cohort" do
              let(:teacher_cohorts) { [] }

              describe "Searching all material types" do

                it "Includes all only blank sequences" do
                  subject.results[Search::InvestigationMaterial].should have(1).items
                end
                it "Includes blank activities and blank externals" do
                  subject.results[Search::ActivityMaterial].should have(2).items
                end
              end
            end

            describe "Teacher in Cohort1" do
              let(:teacher_cohorts) { [cohort1] }

              describe "Searching all material types" do

                it "Includes sequences for cohort1(2), both(1), and unlabled(2)" do
                  subject.results[Search::InvestigationMaterial].should have(4).items
                end
                it "Includes activities for cohort1(4), both(1), and unlabled(2)" do
                  subject.results[Search::ActivityMaterial].should have(7).items
                end
                it "should be not cohort tagged, or include a cohort1 tag" do
                  subject.results[:all].each do |r|
                    unless r.cohorts.empty?
                      r.cohorts.should include(cohort1)
                    end
                  end
                end
              end
            end

            describe "Teacher in Cohort2" do
              let(:teacher_cohorts) { [cohort2] }

              describe "Searching all material types" do

              it "Includes sequences for cohort2(2), both(1), and unlabled(2)" do
                  subject.results[Search::InvestigationMaterial].should have(4).items
                end
                it "Includes activities for cohort2(4), both(1), and unlabled(2)" do
                  subject.results[Search::ActivityMaterial].should have(7).items
                end
                it "should be not cohort tagged, or include a cohort2 tag" do
                  subject.results[:all].each do |r|
                    unless r.cohorts.empty?
                      r.cohorts.should include(cohort2)
                    end
                  end
                end
              end
            end

            describe "Teacher in both cohorts" do
              let(:teacher_cohorts) { [cohort2, cohort1] }

              describe "Searching all material types" do

                it "Includes sequences for cohort1(2) cohort2(2), and unlabled(2)" do
                  subject.results[Search::InvestigationMaterial].should have(6).items
                end
                it "Includes activities for cohort2(4), cohort1(4), and unlabled(2)" do
                  subject.results[Search::ActivityMaterial].should have(10).items
                end
              end
            end

            describe "The teacher is the author of cohort2 activities, but isnt in either cohort" do
              let(:teacher_cohorts)    {[]}
              let(:cohort2_opts) {{:publication_status=>'published', :cohorts => [cohort2], :user_id => mock_user.id} }

              it "Includes sequences for cohort2(2), and unlabled(2)" do
                subject.results[Search::InvestigationMaterial].should have(3).items
              end
              it "Includes activities for cohort2(4), and unlabled(2)" do
                subject.results[Search::ActivityMaterial].should have(6).items
              end
              it "should be not cohort tagged, or include a cohort2 tag" do
                subject.results[:all].each do |r|
                  unless r.cohorts.empty?
                    r.cohorts.should include(cohort2)
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
                  subject.results[Search::InvestigationMaterial].should have(6).items
                end
                it "Includes activities for cohort2(4), cohort1(4), and unlabled(2)" do
                  subject.results[Search::ActivityMaterial].should have(10).items
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
              collection_with_rand_mod_time(:investigation, 6, factory_opts),
              collection_with_rand_mod_time(:activity, 6, factory_opts)
            ].flatten
          end

          describe "Search::Newest" do
            it "the collection should be sorted by updated_at newest ➙ oldest" do
              subject.results[Search::InvestigationMaterial].should be_ordered_by(:updated_at_desc)
              subject.results[Search::ActivityMaterial].should be_ordered_by(:updated_at_desc)
            end
          end

          describe "Search::Oldest" do
            let(:search_opts) { {:private => false, :sort_order => Search::Oldest} }
            it "the collection should be sorted by updated_at oldest ➙ newest" do
              subject.results[Search::InvestigationMaterial].should be_ordered_by(:updated_at)
              subject.results[Search::ActivityMaterial].should be_ordered_by(:updated_at)
            end
          end
        end # by date

        describe "by Popularity" do
          let(:search_opts) { {:private => false, :sort_order => Search::Popularity} }
          let(:factory_opts){ {:publication_status => "published"}         }
          let(:materials) do
            [
              collection(:investigation, 5, factory_opts) do |o|
                o[:offerings_count] = rand(0..10)
              end,
              collection(:external_activity, 5, external_seq.merge(public_opts)) do |o|
                o[:offerings_count] = rand(0..10)
              end,
              collection(:activity, 3, factory_opts) do |o|
                o[:offerings_count] = rand(0..10)
              end,
              collection(:external_activity, 3, external_act.merge(public_opts)) do |o|
                o[:offerings_count] = rand(0..10)
              end
            ].flatten
          end
          it "the collection should be sotred by offerings_count desc" do
            subject.results[Search::InvestigationMaterial].should be_ordered_by(:offerings_count_desc)
            subject.results[Search::ActivityMaterial].should be_ordered_by(:offerings_count_desc)
          end
        end
      end
    end
    describe "#params" do
      before(:each) do
        User.stub!(:find => mock_user)
      end
      subject { params = Search.new(search_opts).params }
      describe "with no options" do
        let(:search_opts) {{}}
        it "should return a hash containing some default values" do
          subject.should include(:activity_page => 1)
          subject.should include(:controller => "search")
          subject.should include(:grade_span => [])
          subject.should include(:investigation_page => 1)
          subject.should include(:material_types => [])
          subject.should include(:per_page => 10)
          subject.should include(:probe => [])
          subject.should include(:sort_order => "Newest")
        end
      end
      describe "with a whole lot of options" do
        let(:search_opts) do
          {
          :private => true,
          :sort => Search::Newest,
          :search_term => "blue",
          :material_types => [Search::InvestigationMaterial, Search::ActivityMaterial],
          :domain_id => ['1','2','4'],
          :user_id => '13',
          :probe => ['0'],
          :grade_span => ['k','12'],
          :activity_page => 3,
          :investigation_page => 7
          }
        end
        it "should return a hash containing all of the options in a hash" do
          subject.should include(:activity_page => 3)
          subject.should include(:controller => "search")
          subject.should include(:grade_span => ["k", "12"])
          subject.should include(:investigation_page => 7)
          subject.should include(:material_types => ["Investigation", "Activity"])
          subject.should include(:per_page => 10)
          subject.should include(:private => true)
          subject.should include(:probe => ["0"])
          subject.should include(:sort_order => "Newest")
          subject.should include(:user_id => "13")
        end
      end
    end

  end
end
