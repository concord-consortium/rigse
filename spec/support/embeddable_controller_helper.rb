shared_examples_for 'an embeddable controller' do
  render_views

  controller_class_lambda = lambda { self.send(:described_class) }
  model_class_lambda      = lambda { controller_class_lambda.call.name[/(.*)Controller/, 1].singularize.constantize }
  model_ivar_name_lambda  = lambda { model_class_lambda.call.name.delete_module.underscore_module }

  def create_new(model_name)
    method_name = "create_new_#{model_name}".to_sym
    if self.respond_to?(method_name)
      return self.send(method_name)
    else
      return Factory.create(model_name)
    end
  end

  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    @model_class = model_class_lambda.call
    @model_ivar_name = model_ivar_name_lambda.call
    unless instance_variable_defined?("@#{@model_ivar_name}".to_sym)
      @model_ivar = instance_variable_set("@#{@model_ivar_name}", create_new(@model_ivar_name))
    end
    login_admin
    @session_options = {
      :secure       => false,
      :secret       => "924cdf373582bbc17ac32060921e6f028a996bb85bbb4b4d7d8cb8c98ef18615a793e676e511e0143708ee7c243c89605bcfdfaa339ed649e58e2fbd6498e117",
      :expire_after => nil,
      :path         => "/",
      :httponly     => true,
      :domain       => nil,
      :key          => "_bort_session",
      :id           => "a0fbca97e9dce0e19ec94ff9afb62b8e",
      :cookie_only  => true
    }
    request.env['rack.session.options'] = @session_options
  end

  describe "GET index" do
    it "runs without error" do
      get :index
      response.should be_success
    end

  end

  describe "GET show" do

    it "assigns the requested #{model_ivar_name_lambda.call} as @#{model_ivar_name_lambda.call}" do
      @model_class.stub!(:find).with("37").and_return(@model_ivar)
      get :show, :id => "37"
      assigns[@model_ivar_name].should equal(@model_ivar)
    end

    it "assigns the requested #{model_ivar_name_lambda.call} as @#{model_ivar_name_lambda.call} when called with Ajax" do
      @model_class.stub!(:find).with("37").and_return(@model_ivar)
      xhr :get, :show, :id => "37"
      assigns[@model_ivar_name].should equal(@model_ivar)
    end

    describe "with mime type of jnlp" do

      it "renders the requested #{model_ivar_name_lambda.call} as jnlp without error" do
        @model_class.stub!(:find).with("37").and_return(@model_ivar)
        get :show, :id => "37", :format => 'jnlp'
        assigns[@model_ivar_name].should equal(@model_ivar)
        response.should render_template("shared/_installer")
        assert_select('jnlp') do
          assert_select('information')
          assert_select('security')
          assert_select('resources')
          assert_select('application-desc') do
            config_url = controller.polymorphic_url(@model_ivar, :format => :config,
                Rails.application.config.session_options[:key] => @session_options[:id])
            assert_select('argument', config_url.gsub("&", "&amp;"))
          end
        end
      end

    end

  end
end
