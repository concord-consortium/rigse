# require File.expand_path('../../spec_helper', __FILE__)

describe SisImporter::Reporter do
  before(:each) do
    options = {}
    path = File.join("tmp","report")
    @transport = mock("transport", {
      :district => 'district',
      :log   => ""
    })
    @reporter = SisImporter::Reporter.new(@transport)
  end

  describe "push_error(csv_row)" do
    before(:each) do
      error = SisImporter::Errors::Error.new("test")
    end
  end

  describe "<< (ar_entity)" do
    before(:each) do
      @ar_entity = mock("thingy")
      @clazz = @ar_entity.class
      @start_time = @reporter.start_time
    end

    describe "When the entity is not valid?" do
      before(:each) do
        @ar_entity.stub!(:valid? => false)
        @reporter << @ar_entity
      end

      it "should show up in the errors list" do
        @reporter.errors(@clazz).should include(@ar_entity)
      end

      it "should not show up in the creates list" do
        @reporter.creates(@clazz).should_not include(@ar_entity)
      end

      it "should not show up in the updates list" do
        @reporter.updates(@clazz).should_not include(@ar_entity)
      end

      it "should not show up in the noops list" do
        @reporter.noops(@clazz).should_not include(@ar_entity)
      end

    end

    describe "When the entity has been recently created" do
      before(:each) do
        @ar_entity.stub!(:valid? => true)
        @ar_entity.stub!(:created_at => Time.now)
        @ar_entity.stub!(:updated_at => Time.now)
        @reporter << @ar_entity
      end

      it "should NOT show up in the errors list" do
        @reporter.errors(@clazz).should_not include(@ar_entity)
      end

      it "should show up in the creates list" do
        @reporter.creates(@clazz).should include(@ar_entity)
      end

      it "should NOT show up in the updates list" do
        @reporter.updates(@clazz).should_not include(@ar_entity)
      end

      it "should NOT show up in the noops list" do
        @reporter.noops(@clazz).should_not include(@ar_entity)
      end
    end

    describe "When the entity has been recently updated" do
      before(:each) do
        @ar_entity.stub!(:valid? => true)
        @ar_entity.stub!(:created_at => 1.hour.ago)
        @ar_entity.stub!(:updated_at => Time.now)
        @reporter << @ar_entity
      end

      it "should NOT show up in the errors list" do
        @reporter.errors(@clazz).should_not include(@ar_entity)
      end

      it "should NOT show up in the creates list" do
        @reporter.creates(@clazz).should_not include(@ar_entity)
      end

      it "should show up in the updates list" do
        @reporter.updates(@clazz).should include(@ar_entity)
      end

      it "should NOT show up in the noops list" do
        @reporter.noops(@clazz).should_not include(@ar_entity)
      end

    end

    describe "When the entity is unchanged" do
      before(:each) do
        @ar_entity.stub!(:valid? => true)
        @ar_entity.stub!(:created_at => 1.hour.ago)
        @ar_entity.stub!(:updated_at => 1.hour.ago)
        @reporter << @ar_entity
      end

      it "should NOT show up in the errors list" do
        @reporter.errors(@clazz).should_not include(@ar_entity)
      end

      it "should NOT show up in the creates list" do
        @reporter.creates(@clazz).should_not include(@ar_entity)
      end

      it "should NOT show up in the updates list" do
        @reporter.updates(@clazz).should_not include(@ar_entity)
      end

      it "should show up in the noops list" do
        @reporter.noops(@clazz).should include(@ar_entity)
      end

    end
  end
end

