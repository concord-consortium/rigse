require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# NOTE: I'm not sure why calling .id on ActiveRecord models (@model, @page, etc) isn't working... calling page[:id] does work, however

describe 'Lab Book Snapshots' do
  
  before(:all) do
    @page = Factory(:page, :user_id => 2)
    @model = Factory(:mw_modeler_page, :user_id => 2, :name => 'mw model', :description => 'mw model', :authored_data_url => 'http://mw2.concord.org/public/student/classic/motion/undershotwaterwheel.cml')
    @model_pe = Factory(:page_element, :page => @page, :embeddable => @model)
    @lab_book_snapshot = Factory(:lab_book_snapshot, :user_id => 2, :name => 'snapshot button', :description => 'snapshot button', :target_element => @model)
    @labbook_pe = Factory(:page_element, :page => @page, :embeddable => @lab_book_snapshot)
  end
  
  before(:each) do
    visit '/logout'
  end
  
  it 'should render the complete target when rendering at the embeddable level' do
    pending 'get webrat working with rspec' do
      visit embeddable_lab_book_snapshot_path(:format => 'otml', :id => @lab_book_snapshot.id)
      response.body.should match(/<OTLabbookButton.*?>.*?<target>.*?<OTModelerPage.*?<\/target>.*?<\/OTLabbookButton>/m)
    end
  end
  
  it 'should only render a reference when rendering at the page level' do
    pending 'get webrat working with rspec' do
      visit page_path(:format => 'otml', :id => @page.id)
      response.body.should match(/<OTLabbookButton.*?>.*?<target>.*?<object refid=.*?<\/target>.*?<\/OTLabbookButton>/m)
    end
  end
  
  it 'should have the correct reference when rendering at the page level' do
    pending 'get webrat working with rspec' do
      refid = '\\$\\{' + @model.class.name.split('::').last.underscore + '_' + @model[:id].to_s + '\\}'
      visit page_path(:format => 'otml', :id => @page[:id])
      regex = Regexp.new("<OTLabbookButton.*?>.*?<target>.*?<object.*?refid=(['\"])#{refid}\\1.*?>.*?<\/target>.*?<\/OTLabbookButton>", Regexp::MULTILINE)
      response.body.should match(regex)
    end
  end
end