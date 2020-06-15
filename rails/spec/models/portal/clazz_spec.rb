require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Clazz do  
  describe "asking if a user is allowed to remove a teacher from a clazz instance" do
    before(:each) do
      @existing_clazz = FactoryBot.create(:portal_clazz)
      @teacher1 = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:user, :login => "teacher1"))
      @teacher2 = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:user, :login => "teacher2"))
    end

    it "under normal circumstances should say there is no reason admins cannot remove teachers" do
      admin_user = FactoryBot.generate(:admin_user)
      @existing_clazz.teachers = [@teacher1, @teacher2]
      expect(@existing_clazz.reason_user_cannot_remove_teacher_from_class(admin_user, @teacher1)).to eq(nil)
    end

    it "under normal circumstances should say there is no reason authorized teachers cannot remove teachers" do
      @existing_clazz.teachers = [@teacher1, @teacher2]
      expect(@existing_clazz.reason_user_cannot_remove_teacher_from_class(@teacher1.user, @teacher2)).to eq(nil)
    end

    it "should say it is illegal for an unauthorized user to remove a teacher" do
      random_user = FactoryBot.generate(:anonymous_user)
      @existing_clazz.teachers = [@teacher1, @teacher2]
      expect(@existing_clazz.reason_user_cannot_remove_teacher_from_class(random_user, @teacher1)).to eq(Portal::Clazz::ERROR_UNAUTHORIZED)
    end

    it "should say it is illegal for a user to remove the last teacher" do
      admin_user = FactoryBot.generate(:admin_user)
      @existing_clazz.teachers = [@teacher1]
      expect(@existing_clazz.reason_user_cannot_remove_teacher_from_class(admin_user, @teacher1)).to eq(Portal::Clazz::ERROR_REMOVE_TEACHER_LAST_TEACHER)
    end
  end

  describe "#changeable?" do
    before(:each) do
      @existing_clazz = FactoryBot.build(:portal_clazz)
    end

    it "is true for admins" do
      admin_user = FactoryBot.generate(:admin_user)
      expect(@existing_clazz.changeable?(admin_user)).to be_truthy
    end

    it "is true for class teacher" do
      @teacher = FactoryBot.create(:portal_teacher)
      @existing_clazz.teachers = [@teacher]
      expect(@existing_clazz.changeable?(@teacher.user)).to be_truthy
    end

    it "is true for second class teacher" do
      @teacher1 = FactoryBot.create(:portal_teacher)
      @teacher2 = FactoryBot.create(:portal_teacher)
      @existing_clazz.teachers = [@teacher1, @teacher2]
      expect(@existing_clazz.changeable?(@teacher2.user)).to be_truthy
    end

    it "is false for non class teacher" do
      @teacher = FactoryBot.create(:portal_teacher)
      expect(@existing_clazz.changeable?(@teacher.user)).to be_falsey
    end
  end

  describe "creating a new class" do
    before(:each) do
      @teacher = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:user, :login => "test_teacher"))
    end

    it "should require a school" do
      # params = {
      #   :name => "Test Class",
      #   :class_word => "123456",
      #   :teacher_id => @teacher.id
      # }
      #
      # new_clazz = Portal::Clazz.new(params)
      # new_clazz.valid?.should == false
      #
      # new_clazz = Portal::Clazz.new(params)
      # new_clazz.valid?.should == true
    end

    it "should require a non blank class name" do
      @course = FactoryBot.create(:portal_course)
      @start_date = DateTime.parse("2009-01-02")
      @section_a = "section a"
      @section_b = "section b"

      @new_clazz = FactoryBot.create(:portal_clazz, {
        :section => @section_a,
        :start_time => @start_date,
        :course => @course,
        :name => 'name',
        :class_word => 'cw'
      })

      @new_clazz.name = ''
      expect(@new_clazz.valid?).to eq(false)

    end

    it "should require a non blank class word" do
      @course = FactoryBot.create(:portal_course)
      @start_date = DateTime.parse("2009-01-02")
      @section_a = "section a"
      @section_b = "section b"

      @new_clazz = FactoryBot.create(:portal_clazz, {
        :section => @section_a,
        :start_time => @start_date,
        :course => @course,
        :name => 'Name',
        :class_word => 'cw'
      })

      @new_clazz.class_word = ''

      expect(@new_clazz.valid?).to eq(false)
    end

  end

  describe ".default_class" do
    it "should return a portal clazz with default_class true" do
      default_class = Portal::Clazz.default_class
      expect(default_class).to be_an_instance_of Portal::Clazz
      expect(default_class.default_class).to be_truthy
    end

    it "should return the same portal clazz on second call" do
      default_clazz = Portal::Clazz.default_class
      expect(default_clazz).to be_an_instance_of Portal::Clazz
      expect(Portal::Clazz.default_class).to eq(default_clazz)
    end
  end

  describe "offerings_including_default_class" do
    before(:each) do
      @clazz             = FactoryBot.create(:portal_clazz)
      @offerings         = []
      @default_offerings = []
      1.upto(10) do |i|
        @offerings << double(:offering,
                           :id => i,
                           :runnable_id => i,
                           :runnable_type => 'bogus',
                           :default => false)

        @default_offerings << double(:offering,
                                   :id => i,
                                   :runnable_id => i,
                                   :runnable_type => 'bogus',
                                   :default => true)
      end
      allow(@clazz).to receive_messages(:active_offerings => @offerings)
    end

    describe "when there are no default activities" do
      before(:each) do
        def_offerings = []
        allow(Portal::Offering).to receive(:find_all_using_runnable_id_and_runnable_type_and_default_offering) { |a,b,c|
          def_offerings.select {|o| o.runnable_id == a}}
      end
      it "should have 10 offerings, zero default offerings" do
        expect(@clazz.offerings_including_default_class.size).to eq(10)
        expect(@clazz.offerings_including_default_class.select{ |i| i.default == true}.size).to eq(0)
      end
    end

    describe "when there is 100% overlap with default activities" do
      before(:each) do
        def_offerings = @default_offerings
        allow(Portal::Offering).to receive(:find_all_using_runnable_id_and_runnable_type_and_default_offering) { |a,b,c|
          def_offerings.select {|o| o.runnable_id == a}}
      end
      it "should have 10 offerings, 10 default offerings" do
        expect(@clazz.offerings_including_default_class.size).to eq(10)
        expect(@clazz.offerings_including_default_class.select{ |i| i.default == true}.size).to eq(10)
      end
    end

    describe "the first half are default activities" do
      before(:each) do
        def_offerings = @default_offerings[0...5]
        allow(Portal::Offering).to receive(:find_all_using_runnable_id_and_runnable_type_and_default_offering) { |a,b,c|
          def_offerings.select {|o| o.runnable_id == a}}
      end
      it "should have 10 offerings, 5 default offerings" do
        expect(@clazz.offerings_including_default_class.size).to eq(10)
        expect(@clazz.offerings_including_default_class.select{ |i| i.default == true}.size).to eq(5)
      end
    end

    describe "the first half are default activities" do
      before(:each) do
        def_offerings = @default_offerings[5...10]
        allow(Portal::Offering).to receive(:find_all_using_runnable_id_and_runnable_type_and_default_offering) { |a,b,c|
          def_offerings.select {|o| o.runnable_id == a}}
      end
      it "should have 10 offerings, 5 default offerings" do
        expect(@clazz.offerings_including_default_class.size).to eq(10)
        expect(@clazz.offerings_including_default_class.select{ |i| i.default == true}.size).to eq(5)
      end
    end

    describe "every other activity is the default default" do
      before(:each) do
        def_offerings = @default_offerings.select { |i| i.runnable_id % 2 == 0 }
        allow(Portal::Offering).to receive(:find_all_using_runnable_id_and_runnable_type_and_default_offering) { |a,b,c|
          def_offerings.select {|o| o.runnable_id == a}}
      end
      it "should have 10 offerings, 5 default offerings" do
        expect(@clazz.offerings_including_default_class.size).to eq(10)
        expect(@clazz.offerings_including_default_class.select{ |i| i.default == true}.size).to eq(5)
      end
    end
  end

  # def offerings_with_default_classes(user=nil)
  #   return self.offerings_including_default_class unless (user && user.portal_student && self.default_class)
  #   real_offerings = user.portal_student.clazzes.map{ |c| c.active_offerings }.flatten.uniq.compact
  #   default_offerings = self.active_offerings.reject { |o| real_offerings.include?(o) }
  #   default_offerings
  # end
  describe "offerings_with_default_classes" do
    before(:each) do
      @clazz = FactoryBot.create(:portal_clazz, :default_class => false)
    end
    describe "called without a user" do
      it "should fall back to offerings_including_default_class" do
        expect(@clazz).to receive(:offerings_including_default_class).and_return(true)
        expect(@clazz.offerings_with_default_classes).to eq(true)
      end
    end
    describe "called without a student" do
      before(:each) do
        @user = double(:user, :portal_student => nil)
      end
      it "should fall back to offerings_including_default_class" do
        expect(@clazz).to receive(:offerings_including_default_class).and_return(true)
        expect(@clazz.offerings_with_default_classes(@user)).to eq(true)
      end
    end
    describe "when not the default class" do
      before(:each) do
        @offerings = [double(:offering),double(:offering)]
        @clazzes = [double(:clazz, :offerings => @offerings)]
        @student = double(:student, :clazzes => @clazzes)
        @user = double(:user, :portal_student => @student)
      end
      it "should fall back to offerings_including_default_class" do
        expect(@clazz).to receive(:default_class).and_return(false)
        expect(@clazz).to receive(:offerings_including_default_class).and_return(true)
        expect(@clazz.offerings_with_default_classes(@user)).to eq(true)
      end
    end
    describe "when the default class, and when there is a user" do
      before(:each) do
        @offerings = []
        # these offerings belong to the "real" class
        0.upto(2) do |i|
          @offerings << double(:offering, :id => i, :runnable_type => 'fake', :runnable => i, :runnable_id => i)
        end
        @student_offerings = @offerings[0..2]

        # these offerings belong to the default class but have the same runnable as the first 2 student offerings
        3.upto 4 do |i|
          @offerings << double(:offering, :id => i, :runnable_type => 'fake', :runnable => i-3, :runnable_id => i-3)
        end
        @default_offerings_with_same_runnable_as_a_student_offering = @offerings[3..4]

        # these offerings belong only to the default class
        5.upto 8 do |i|
          @offerings << double(:offering, :id => i, :runnable_type => 'fake', :runnable => i, :runnable_id => i)
        end
        @default_offerings_with_unique_runnable = @offerings[5..8]
        @default_offerings = @offerings[3..8]

        @clazzes = [double(:clazz, :active_offerings => @student_offerings, :default_class => false),@clazz]
        @student = double(:student, :clazzes => @clazzes)
        @user = double(:user, :portal_student => @student)
        allow(@clazz).to receive_messages(:default_class => true)
        allow(@clazz).to receive_messages(:active_offerings => @default_offerings)
      end
      it "should not fall back to offerings_including_default_class" do
        expect(@clazz).not_to receive(:offerings_including_default_class)
        expect(@clazz.offerings_with_default_classes(@user)).not_to be_nil
      end
      it "should not contain the offerings which use the same runnable as a student offering" do
        default_class_offerings = @clazz.offerings_with_default_classes(@user)
        @default_offerings_with_same_runnable_as_a_student_offering.each do |o|
          expect(default_class_offerings).not_to include(o)
        end
      end
      it "should contain exactly the offerings which do not use the same runnable as a student offering" do
        default_class_offerings = @clazz.offerings_with_default_classes(@user)
        expect(default_class_offerings.size).to eq(@default_offerings_with_unique_runnable.length)
        @default_offerings_with_unique_runnable.each do |o|
          expect(default_class_offerings).to include(o)
        end
      end
    end

  end

  describe "formatting methods" do
    before :each do
      @clazz = FactoryBot.create(:portal_clazz)
      @bob   = mock_model(Portal::Teacher, :name => "bob")
      @joan  = mock_model(Portal::Teacher, :name => "joan")
    end

    context "with no teachers" do
      subject do
        allow(@clazz).to receive_messages :teachers => []
        @clazz
      end

      describe '#teachers_label' do
        subject { super().teachers_label }
        it {is_expected.to eq("Teacher")      }
      end

      describe '#teachers_listing' do
        subject { super().teachers_listing }
        it {is_expected.to eq("no teachers") }
      end
    end

    context "With one teacher" do
      subject do
        allow(@clazz).to receive_messages :teachers => [@joan]
        @clazz
      end

      describe '#teachers_label' do
        subject { super().teachers_label }
        it {is_expected.to eq("Teacher")         }
      end

      describe '#teachers_listing' do
        subject { super().teachers_listing }
        it {is_expected.to match @joan.name      }
      end

      describe '#teachers_listing' do
        subject { super().teachers_listing }
        it {is_expected.not_to match @bob.name }
      end
    end

    context "With two teachers" do
      subject do
        allow(@clazz).to receive_messages :teachers => [@bob,@joan]
        @clazz
      end

      describe '#teachers_label' do
        subject { super().teachers_label }
        it {is_expected.to eq("Teachers")    }
      end

      describe '#teachers_listing' do
        subject { super().teachers_listing }
        it {is_expected.to match @bob.name  }
      end

      describe '#teachers_listing' do
        subject { super().teachers_listing }
        it {is_expected.to match @joan.name }
      end
    end
  end

end
