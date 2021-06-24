require 'spec_helper'

describe ApplicationHelper, type: :helper do
  include ApplicationHelper
  attr_accessor :page_title

  describe "title" do
    it "should set @page_title" do
      expect(title_tag('hello')).to be_nil
      expect(page_title).to eql('hello')
    end

    it "should output container if set" do
      expect(title_tag('hello', :h2)).to have_selector('h2', :text => 'hello')
    end
  end

  describe "login_line" do
    before(:each) do
      @anonymous_user = mock_model(User, :roles => ["guest"], :anonymous? => true, :name => "guest")
      @admin_user = mock_model(User, :roles => ["admin"], :anonymous? => false, :name => "admin", :has_role? => true)
    end

    describe "as anonymous" do
      before(:each) do
        allow(self).to receive(:current_visitor).and_return(@anonymous_user)
        @original_user = @anonymous_user
      end
      it "should display appropriate login messages" do
        expect(login_line).to match(/login/i)
        expect(login_line).not_to match(/welcome/i)
        expect(login_line(:guest => "guest")).to match(/welcome\s*guest/i)
        expect(login_line(:login => "Log In")).to match(/Log In/)
        expect(login_line(:signup => "Sign Up")).to match(/Sign Up/)
      end
    end

    describe "as admin" do
      before(:each) do
        allow(self).to receive(:current_visitor).and_return(@admin_user)
        @original_user = @admin_user
      end
      it "should display appropriate login messages" do
        expect(login_line).to match(/log\s*out/i)
        expect(login_line).to match(/switch/i)
        expect(login_line(:logout => "Log Out")).to match(/Log Out/)
      end
    end
  end

  let(:component) { User.new }
  let(:model) { User.new }


  before(:each) do
    @admin_user = mock_model(User, :roles => ["admin"], :anonymous? => false, :name => "admin", :has_role? => true)

    allow(self).to receive(:current_visitor).and_return(@admin_user)
    @original_user = @admin_user
  end
  # TODO: auto-generated
  describe '#current_settings' do
    it 'works' do
      result = helper.current_settings

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#top_level_container_name' do
    it 'works' do
      result = helper.top_level_container_name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#dom_id_for' do
    it 'works' do
      result = helper.dom_id_for(component, [])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#dom_class_for' do
    it 'works' do
      result = helper.dom_class_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#short_name' do
    it 'works' do
      result = helper.short_name('name')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#title_tag' do
    it 'works' do
      result = helper.title_tag('cc', 'container')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#flash_messages' do
    it 'works' do
      result = helper.flash_messages

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#labeled_check_box' do
    xit 'works' do
      result = helper.labeled_check_box(form, field, name)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#check_box_tag_new' do
    it 'works' do
      result = helper.check_box_tag_new('name', 'value')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#render_top_level_container_list_partial' do
    xit 'works' do
      result = helper.render_top_level_container_list_partial({})

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#top_level_container_name_as_class_string' do
    it 'works' do
      result = helper.top_level_container_name_as_class_string

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#render_partial_for' do
    xit 'works' do
      result = helper.render_partial_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#render_show_partial_for' do
    xit 'works' do
      result = helper.render_show_partial_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#render_edit_partial_for' do
    xit 'works' do
      result = helper.render_edit_partial_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_url_for' do
    it 'works' do
      result = helper.edit_url_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_menu_for' do
    xit 'works' do
      result = helper.edit_menu_for(component, form)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#accordion_for' do
    xit 'works' do
      result = helper.accordion_for(model, 'title', "dom_prefix")

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#sort_dropdown' do
    it 'works' do
      result = helper.sort_dropdown('selected', 'keep')

      expect(result).not_to be_nil
    end
  end


  # TODO: auto-generated
  describe '#learner_report_link_for' do
    xit 'works' do
      result = helper.learner_report_link_for(FactoryBot.create(:full_portal_learner), 'action', 'link_text', 'title')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#report_link_for' do
    xit 'works' do
      result = helper.report_link_for('reportable', 'link_text', 'title')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#activation_toggle_link_for' do
    xit 'works' do
      result = helper.activation_toggle_link_for('activatable', 'action', 'link_text', 'title')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_link_for' do
    xit 'works' do
      result = helper.edit_link_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#duplicate_link_for' do
    xit 'works' do
      result = helper.duplicate_link_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#print_link_for' do
    it 'works' do
      result = helper.print_link_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#link_to_container' do
    xit 'works' do
      result = helper.link_to_container('container')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#title_for_component' do
    xit 'works' do
      result = helper.title_for_component(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name_for_component' do
    it 'works' do
      result = helper.name_for_component(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#sessions_learner_stat' do
    xit 'works' do
      result = helper.sessions_learner_stat(FactoryBot.create(:portal_learner))

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#learner_specific_stats' do
    xit 'works' do
      result = helper.learner_specific_stats(FactoryBot.create(:portal_learner))

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#report_details_for_learner' do
    xit 'works' do
      result = helper.report_details_for_learner(FactoryBot.create(:portal_learner))

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#report_correct_count_for_learner' do
    xit 'works' do
      result = helper.report_correct_count_for_learner(FactoryBot.create(:portal_learner))

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#percent' do
    it 'works' do
      result = helper.percent(1, 2, 3)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#percent_str' do
    it 'works' do
      result = helper.percent_str(1, 2, 3)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#menu_for_learner' do
    xit 'works' do
      result = helper.menu_for_learner(FactoryBot.create(:portal_learner), {})

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#lara_report_link' do
    it 'works' do
      result = helper.lara_report_link(FactoryBot.build(:portal_offering))

      expect(result).to be_nil
    end
  end



  # TODO: auto-generated
  describe '#link_button' do
    it 'works when we stub out the compute_asset_path method' do
      # 2021-06-01 -- This doesn't work any more because the asset packaging
      # pipeline expects an image named 'image' to exist in the pipeline.
      expect(helper).to receive(:compute_asset_path).and_return("image")
      result = helper.link_button('image', 'url')
      expect(result).not_to be_nil

    end
    it 'works if we give it a valid image from the asset path too' do
      result = helper.link_button('cc-logo', 'url')
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#tab_for' do
    it 'works' do
      result = helper.tab_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#style_for_teachers' do
    it 'works' do
      result = helper.style_for_teachers(component, [])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#style_for_item' do
    it 'works' do
      result = helper.style_for_item(component, [])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#simple_div_helper_that_yields' do
    xit 'works' do
      result = helper.simple_div_helper_that_yields

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#already_rendered?' do
    it 'works' do
      result = helper.already_rendered?('thing')

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#mark_rendered' do
    it 'works' do
      result = helper.mark_rendered('thing')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#in_render_scope?' do
    it 'works' do
      result = helper.in_render_scope?('thing')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#render_scoped_reference' do
    xit 'works' do
      result = helper.render_scoped_reference('thing')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#for_teacher_only?' do
    it 'works' do
      result = helper.for_teacher_only?('thing')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#render_project_info' do
    it 'works' do
      result = helper.render_project_info

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_top_menu_item' do
    it 'works' do
      result = helper.add_top_menu_item('link')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#runnable_list' do
    xit 'works' do
      result = helper.runnable_list({})

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#students_in_class' do
    it 'works' do
      result = helper.students_in_class([])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#login_line' do
    xit 'works' do
      result = helper.login_line({})

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#settings_for' do
    it 'works' do
      result = helper.settings_for('key')

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#current_user_can_author' do
    xit 'works' do

      result = helper.current_user_can_author

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#with_format' do
    it 'works' do
      result = helper.with_format(:html)  {}

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_settings_index_path' do
    it 'works' do
      result = helper.admin_settings_index_path([])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#class_link_for_user' do
    xit 'works' do
      result = helper.class_link_for_user

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#current_user_home_path' do
    xit 'works' do
      result = helper.current_user_home_path

      expect(result).not_to be_nil
    end
  end


end
