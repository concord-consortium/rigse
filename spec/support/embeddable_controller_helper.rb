shared_examples_for 'an embeddable controller' do
  integrate_views
  
  controller_class_lambda = lambda { self.send(:described_class) }
  model_class_lambda      = lambda { controller_class_lambda.call.name[/(.*)Controller/, 1].singularize.constantize }
  model_ivar_name_lambda  = lambda { model_class_lambda.call.name.delete_module.underscore_module }

  def with_tags_like_an_otml(model_name)
    self.send("with_tags_like_an_otml_#{model_name}".to_sym)
  end

  def create_new(model_name)
    method_name = "create_new_#{model_name}".to_sym
    if self.respond_to?(method_name)
      return self.send(method_name)
    else
      return Factory.create(model_name)
    end
  end

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    @model_class = model_class_lambda.call
    @model_ivar_name = model_ivar_name_lambda.call
    unless instance_variable_defined?("@#{@model_ivar_name}".to_sym)
      @model_ivar = instance_variable_set("@#{@model_ivar_name}", create_new(@model_ivar_name))
    end    
    login_admin
    @session_options = {
      :secure=>false, 
      :secret=>"924cdf373582bbc17ac32060921e6f028a996bb85bbb4b4d7d8cb8c98ef18615a793e676e511e0143708ee7c243c89605bcfdfaa339ed649e58e2fbd6498e117", 
      :expire_after=>nil, 
      :path=>"/", 
      :httponly=>true, 
      :domain=>nil, 
      :key=>"_bort_session", 
      :id=>"a0fbca97e9dce0e19ec94ff9afb62b8e", 
      :cookie_only=>true
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
        response.should render_template("shared/_show.jnlp.builder")
        response.should have_tag('jnlp') do
          with_tag('information')
          with_tag('security')
          with_tag('resources')
          with_tag('application-desc') do
            with_tag('argument', controller.polymorphic_url(@model_ivar, :format => :config, :teacher_mode => false, :session => @session_options[:id]))
          end
        end
      end    
  
    end
  
    describe "with mime type of config" do
  
      it "renders the requested #{model_ivar_name_lambda.call} as config without error" do
        @model_class.stub!(:find).with("37").and_return(@model_ivar)
        get :show, :id => "37", :format => 'config'
        assigns[@model_ivar_name].should equal(@model_ivar)
        response.should render_template("shared/_show.config.builder")
        response.should have_tag('java') do
          with_tag('object[class=?]', 'net.sf.sail.core.service.impl.LauncherServiceImpl') do
            with_tag('void[property=?]', 'properties') do
              with_tag('object[class=?]', 'java.util.Properties') do
                with_tag('void[method=?]', 'setProperty') do
                  with_tag('string', controller.polymorphic_url(@model_ivar, :format => :dynamic_otml, :teacher_mode => false))
                end
              end
            end
          end
        end
      end
  
    end
    
    describe "with mime type of dynamic_otml" do
    
      it "renders the requested #{model_ivar_name_lambda.call} as dynamic_otml without error" do
        @model_class.stub!(:find).with("37").and_return(@model_ivar)
        get :show, :id => "37", :format => 'dynamic_otml'
        assigns[@model_ivar_name].should equal(@model_ivar)
        response.should have_tag('otrunk') do
          with_tag('imports')
          with_tag('objects') do
            with_tag('OTSystem') do
              with_tag('includes') do
                with_tag('OTInclude[href=?]', controller.polymorphic_url(@model_ivar, :format => :otml, :teacher_mode => false))
              end
              with_tag('bundles') do
                with_tag('OTInterfaceManager[local_id=?]', 'interface_manager') do
                  with_tag('deviceConfigs') do
                    with_tag('OTDeviceConfig')
                  end
                end
              end
              with_tag('overlays')
              with_tag('root') do
                with_tag('object')
              end
            end
          end
        end
      end
    
    end
  
    describe "with mime type of otml" do
    
      it "renders the requested #{model_ivar_name_lambda.call} as otml without error" do
        @model_class.stub!(:find).with("37").and_return(@model_ivar)
        get :show, :id => "37", :format => 'otml'
        assigns[@model_ivar_name].should equal(@model_ivar)
        response.should render_template(:show)
        response.should have_tag('otrunk') do
          with_tag('imports')
          with_tag('objects') do
            with_tag('OTSystem') do
              with_tag('bundles') do
                with_tag('OTViewBundle') do
                  with_tag('frame')
                  with_tag('modes')
                  with_tag('views')
                end
                with_tag('OTInterfaceManager[local_id=?]', 'interface_manager') do
                  with_tag('deviceConfigs') do
                    with_tag('OTDeviceConfig')
                  end
                end
                with_tag('OTScriptEngineBundle[local_id=?]', 'script_engine_bundle') do
                  with_tag('engines') do
                    with_tag('OTScriptEngineEntry')
                  end
                end
                with_tag('OTLabbookBundle')
              end
              with_tag('root') do
                with_tag('OTCompoundDoc') do
                  with_tag('bodyText')
                end
              end
              with_tag('library') do
                with_tags_like_an_otml(@model_ivar_name)
               end
            end
          end
        end
      end
    
    end
    
  end
  
  if model_class_lambda.call.respond_to?(:authorable_in_java?) && model_class_lambda.call.authorable_in_java?
    
    describe "GET edit" do

      it "assigns the requested #{model_ivar_name_lambda.call} as @#{model_ivar_name_lambda.call}" do
        @model_class.stub!(:find).with("37").and_return(@model_ivar)
        get :edit, :id => "37"
        assigns[@model_ivar_name].should equal(@model_ivar)
      end

      describe "with mime type of jnlp" do

        it "renders the requested #{model_ivar_name_lambda.call} as jnlp without error" do
          @model_class.stub!(:find).with("37").and_return(@model_ivar)
          get :edit, :id => "37", :format => 'jnlp'
          assigns[@model_ivar_name].should equal(@model_ivar)
          response.should render_template("shared/_edit.jnlp.builder")
          response.should have_tag('jnlp') do
            with_tag('information')
            with_tag('security')
            with_tag('resources')
            with_tag('application-desc') do
              with_tag('argument', controller.polymorphic_url(@model_ivar, :format => :config, :teacher_mode => false, :session => @session_options[:id], :action => 'edit'))
            end
          end
        end

      end

      describe "with mime type of config" do

        it "renders the requested #{model_ivar_name_lambda.call} as config without error" do
          @model_class.stub!(:find).with("37").and_return(@model_ivar)
          get :edit, :id => "37", :format => 'config', :session => '6ee4ff32b48026db6f3758da9f090150'
          assigns[@model_ivar_name].should equal(@model_ivar)
          response.should render_template("shared/_edit.config.builder")
          response.should have_tag('java') do
            with_tag('object') do
              with_tag('void') do
                with_tag('object') do
                  with_tag('void') do
                    with_tag('string', controller.polymorphic_url(@model_ivar, :format => :dynamic_otml, :teacher_mode => false, :action => 'edit'))
                  end
                end
              end
            end
          end
        end

      end

      describe "with mime type of dynamic_otml" do

        it "renders the requested #{model_ivar_name_lambda.call} as dynamic_otml without error" do
          @model_class.stub!(:find).with("37").and_return(@model_ivar)
          get :edit, :id => "37", :format => 'dynamic_otml', :session => '6ee4ff32b48026db6f3758da9f090150'
          assigns[@model_ivar_name].should equal(@model_ivar)
          response.should render_template("shared/_edit.dynamic_otml.builder")
          response.should have_tag('otrunk') do
            with_tag('imports')
            with_tag('objects') do
              with_tag('OTSystem') do
                with_tag('includes') do
                  # with_tag('OTInclude')
                  with_tag('OTInclude[href=?]', controller.polymorphic_url(@model_ivar, :format => :otml, :teacher_mode => false, :action => 'edit'))
                end
                with_tag('bundles')
                with_tag('overlays')
                with_tag('root')
              end
            end
          end
        end

      end

      describe "with mime type of otml" do

        it "renders the requested #{model_ivar_name_lambda.call} as otml without error" do
          @model_class.stub!(:find).with("37").and_return(@model_ivar)
          get :edit, :id => "37", :format => 'otml'
          assigns[@model_ivar_name].should equal(@model_ivar)
          response.should render_template(:edit)
          response.should have_tag('otrunk') do
            with_tag('imports')
            with_tag('objects') do
              with_tag('OTSystem') do
                with_tag('bundles')
                with_tag('root')
                with_tag('library') do
                  with_tags_like_an_otml(@model_ivar_name)
                end
              end
            end
          end
        end

      end

    end
    
  end

end
