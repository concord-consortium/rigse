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
      it "should remove emdashes" do
        Search.clean_search_terms("balrgs – bonk").should == "balrgs  bonk"
      end
      it "should remove question marks" do
        Search.clean_search_terms("balrgs ? bonk").should == "balrgs  bonk"
      end
      it "should remove ampersands" do
        Search.clean_search_terms("balrgs & bonk").should == "balrgs  bonk"
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
    let(:mock_user)      { mock_model(User, :cohort_list => []) }
    before(:all) do
      solr_setup
      clean_solar_index
    end

    after(:each) do
      clean_solar_index
    end

    let(:official)     { { :is_official => true }}
    let(:public_opts)  { { :publication_status => "published"}}
    let(:private_opts) { { :publication_status => "private"          }}
    let(:external_seq) { { :template => private_investigations.first }}
    let(:external_act) { { :template => private_activities.first     }}

    let(:public_investigations) { collection(:investigation, 2, public_opts) }
    let(:private_investigations){ collection(:investigation, 2, private_opts)}
    let(:public_activities)     { collection(:activity, 2, public_opts)      }
    let(:private_activities)    { collection(:activity, 2, private_opts)     }
    let(:public_ext_act)        { collection(:external_activity, 2, external_act.merge(public_opts).merge(official))  }
    let(:private_ext_act)       { collection(:external_activity, 2, external_act.merge(private_opts).merge(official)) }
    let(:public_ext_seq)        { collection(:external_activity, 2, external_seq.merge(public_opts).merge(official))  }
    let(:private_ext_seq)       { collection(:external_activity, 2, external_seq.merge(private_opts).merge(official)) }

    let(:search_opts) { {} }

    subject do
      s = Search.new(search_opts)
    end

    context "with existing collections" do
      let(:private_items) { [private_investigations, private_activities, private_ext_act, private_ext_seq].flatten}
      let(:public_items)  { [public_investigations,  public_activities, public_ext_act,  public_ext_seq].flatten}
      let(:materials)     { [public_items, private_items].flatten }

      before(:each) do
        make materials
        Sunspot.index!
      end

      describe "searching public items" do
        let(:search_opts) { {:private => false } }
        it "results should include 4 public activities and 4 public investigations" do
          subject.results[:all].should have(8).entries
          subject.results[Search::InvestigationMaterial].should have(4).entries
          subject.results[Search::ActivityMaterial].should have(4).entries
        end
      end

      describe "searching all items" do
        let(:search_opts) { {:private => true } }
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
              it "should not be listed in the  results" do
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
          let(:external_activity){FactoryGirl.create(:external_activity, public_opts.merge(official))}
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
        let(:teacher_cohorts) {[]}
        let(:mock_user)       { mock_model(User, :id => 23, :cohort_list => teacher_cohorts)}
        let(:search_opts)     {{ :private => false, :user_id => mock_user.id }}
        before(:each) do
          User.stub!(:find => mock_user)
        end
        describe "With two defined cohorts"  do
          describe "With activities in every combination of cohorts " do
            let(:cohort1_opts) {{:publication_status=>'published', :cohort_list => 'cohort1' }}
            let(:cohort2_opts) {{:publication_status=>'published', :cohort_list => 'cohort2' }}

            let(:cohort1_sequences) { collection(:investigation, 2, cohort1_opts)}
            let(:cohort2_sequences) { collection(:investigation, 2, cohort2_opts)}

            let(:cohort1_activities) { collection(:activity, 2, cohort1_opts)}
            let(:cohort2_activities) { collection(:activity, 2, cohort2_opts)}

            let(:cohort1_externals) { collection(:external_activity, 2, cohort1_opts.merge(official))}
            let(:cohort2_externals) { collection(:external_activity, 2, cohort2_opts.merge(official))}
            let(:materials) do
              [
                cohort1_sequences, cohort1_activities, cohort1_externals,
                cohort2_sequences, cohort2_activities, cohort2_externals
              ].flatten
            end

            describe "A teacher in cohort1" do
              let(:teacher_cohorts) { 'cohort1' }

              describe "Searching all material types"

                it "Includes sequences for cohort1" do
                  subject.results[Search::InvestigationMaterial].should have(2).items
                  subject.results[Search::InvestigationMaterial].each do |i|
                    i.cohort_list.should include('cohort1')
                  end
                end
                it "Includes activities for cohort1" do
                  subject.results[Search::ActivityMaterial].should have(4).items
                  subject.results[Search::ActivityMaterial].each do |i|
                    i.cohort_list.should include('cohort1')
                  end
                end

                it "Doesn't include sequences for cohort2" do
                  subject.results[Search::InvestigationMaterial].each do |i|
                    i.cohort_list.should_not include('cohort2')
                  end
                end
                it "Doesn't include activities for cohort2" do
                  subject.results[Search::ActivityMaterial].each do |i|
                    i.cohort_list.should_not include('cohort2')
                  end
                end

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
      subject { params = Search.new(search_opts).params }
      describe "with no options" do
        let(:search_opts) {{}}
        it "should return a hash containing some default values" do
          subject.should include(:activity_page => 1)
          subject.should include(:controller => "search")
          subject.should include(:grade_span => [])
          subject.should include(:investigation_page => 1)
          subject.should include(:material_types => ["Investigation", "Activity"])
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