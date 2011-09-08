shared_examples_for 'an embeddable controller' do
  render_views

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
        response.should render_template("shared/_show.jnlp.builder")
        assert_select('jnlp') do
          assert_select('information')
          assert_select('security')
          assert_select('resources')
          assert_select('application-desc') do
            assert_select('argument', controller.polymorphic_url(@model_ivar, :format => :config, :teacher_mode => false, @session_options[:key] => @session_options[:id]))
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
        assert_select('java') do
          assert_select('object[class=?]', 'net.sf.sail.core.service.impl.LauncherServiceImpl') do
            assert_select('void[property=?]', 'properties') do
              assert_select('object[class=?]', 'java.util.Properties') do
                assert_select('void[method=?]', 'setProperty') do
                  assert_select('string', controller.polymorphic_url(@model_ivar, :format => :dynamic_otml, :teacher_mode => false))
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
        assert_select('otrunk') do
          assert_select('imports')
          assert_select('objects') do
            assert_select('OTSystem') do
              assert_select('includes') do
                assert_select('OTInclude[href=?]', controller.polymorphic_url(@model_ivar, :format => :otml, :teacher_mode => false))
              end
              assert_select('bundles') do
                assert_select('OTInterfaceManager[local_id=?]', 'interface_manager') do
                  assert_select('deviceConfigs') do
                    assert_select('OTDeviceConfig')
                  end
                end
              end
              assert_select('overlays')
              assert_select('root') do
                assert_select('object')
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
        puts "================"
        puts response.body
        assert_select('otrunk') do
          assert_select('imports')
          assert_select('objects') do
            assert_select('OTSystem') do
              assert_select('bundles') do
                assert_select('OTViewBundle') do
                  assert_select('frame')
                  assert_select('modes')
                  assert_select('views')
                end
                assert_select('OTInterfaceManager[local_id=?]', 'interface_manager') do
                  assert_select('deviceConfigs') do
                    assert_select('OTDeviceConfig')
                  end
                end
                assert_select('OTScriptEngineBundle[local_id=?]', 'script_engine_bundle') do
                  assert_select('engines') do
                    assert_select('OTScriptEngineEntry')
                  end
                end
                assert_select('OTLabbookBundle')
              end
              assert_select('root') do
                assert_select('OTCompoundDoc') do
                  assert_select('bodyText')
                end
              end
              assert_select('library') do
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
          assert_select('jnlp') do
            assert_select('information')
            assert_select('security')
            assert_select('resources')
            assert_select('application-desc') do
              assert_select('argument', controller.polymorphic_url(@model_ivar, :format => :config, :teacher_mode => false, @session_options[:key] => @session_options[:id], :action => 'edit'))
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
          assert_select('java') do
            assert_select('object') do
              assert_select('void') do
                assert_select('object') do
                  assert_select('void') do
                    assert_select('string', controller.polymorphic_url(@model_ivar, :format => :dynamic_otml, :teacher_mode => false, :action => 'edit'))
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
          assert_select('otrunk') do
            assert_select('imports')
            assert_select('objects') do
              assert_select('OTSystem') do
                assert_select('includes') do
                  # assert_select('OTInclude')
                  assert_select('OTInclude[href=?]', controller.polymorphic_url(@model_ivar, :format => :otml, :teacher_mode => false, :action => 'edit'))
                end
                assert_select('bundles')
                assert_select('overlays')
                assert_select('root')
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
          assert_select('otrunk') do
            assert_select('imports')
            assert_select('objects') do
              assert_select('OTSystem') do
                assert_select('bundles')
                assert_select('root')
                assert_select('library') do
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
