require File.expand_path('../../../spec_helper', __FILE__)


describe Report::Learner do
  before(:each) do
    @user     = mock_model(User,
      :name => "joe"
    )

    @student  = mock_model(Portal::Student,
      :user => @user,
      :permission_forms => []
    )

    @runnable = mock_model(ExternalActivity)

    @class    = mock_model(Portal::Clazz,
      :school   => mock_model(Portal::School, :name => "my school"),
      :teachers => []
    )

    @offering = mock_model(Portal::Offering,
      :runnable => @runnable,
      :clazz    => @class,
      :name     => "offering",
      :report_embeddable_filter => nil,
      :reload => nil
    )

    @learner  = mock_model(Portal::Learner,
      :student  => @student,
      :offering => @offering
    )
  end

  it "should create a valid instance with adequate mocks" do
    @report = Report::Learner.create(:learner => @learner)
  end

  describe "with a learner" do
    it "the last_run time should be nil" do
      report = Report::Learner.create(:learner => @learner)
      expect(report.last_run).to be_nil
    end
  end

  describe "with_permission_ids" do
    let(:permission_form_a) { FactoryBot.create(:permission_form) }

    let(:permission_form_b) { FactoryBot.create(:permission_form) }

    let(:offering) { FactoryBot.create(:portal_offering) }

    let(:report_learner_a) do
      student = FactoryBot.create(:full_portal_student,
        permission_forms: [permission_form_a]
      )

      learner = FactoryBot.create(:portal_learner,
        offering: offering,
        student: student)

      Report::Learner.create(:learner => learner)
    end

    let(:report_learner_b) do
      student = FactoryBot.create(:full_portal_student,
        permission_forms: [permission_form_b]
      )

      learner = FactoryBot.create(:portal_learner,
        offering: offering,
        student: student)

      Report::Learner.create(:learner => learner)
    end

    it "should not return a learner without the permission_id" do
      report_learner_a
      expect(Report::Learner.with_permission_ids([99999]).count).to eq(0)
    end

    it "should return a learner with with the correct permission_id" do
      report_learner_a
      report_learner_b
      expect(Report::Learner.with_permission_ids([permission_form_a.id]).count).to eq(1)
    end

  end


  # TODO: auto-generated
  describe '.after' do # scope test
    it 'supports named scope after' do
      expect(described_class.limit(3).after(Date.current)).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.before' do # scope test
    it 'supports named scope before' do
      expect(described_class.limit(3).before(Date.current)).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.in_schools' do # scope test
    it 'supports named scope in_schools' do
      expect(described_class.limit(3).in_schools([1])).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.in_classes' do # scope test
    it 'supports named scope in_classes' do
      expect(described_class.limit(3).in_classes([1])).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.with_permission_ids' do # scope test
    it 'supports named scope with_permission_ids' do
      expect(described_class.limit(3).with_permission_ids([1])).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.with_runnables' do # scope test
    it 'supports named scope with_runnables' do
      expect(described_class.limit(3).with_runnables([User.new])).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#ensure_no_nils' do
    it 'ensure_no_nils' do
      learner = described_class.new
      result = learner.ensure_no_nils

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#last_run_string' do
    it 'last_run_string' do
      learner = described_class.new
      opts = {}
      result = learner.last_run_string(opts)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.build_last_run_string' do
    it 'build_last_run_string' do
      last_run = Time.now
      opts = {}
      result = described_class.build_last_run_string(last_run, opts)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.encode_answer_key' do
    it 'encode_answer_key' do
      item = described_class.new
      result = described_class.encode_answer_key(item)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.decode_answer_key' do
    it 'decode_answer_key' do
      answer_key = 'abc'
      result = described_class.decode_answer_key(answer_key)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_field' do
    it 'update_field' do
      learner = described_class.new
      methods_string = 'methods_string'
      field = double('field')
      result = learner.update_field(methods_string, field) { |value| }

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_fields' do
    xit 'update_fields' do
      learner = described_class.new
      result = learner.update_fields

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#escape_comma' do
    it 'escape_comma' do
      learner = described_class.new
      string = 'string'
      result = learner.escape_comma(string)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_teacher_info_fields' do
    it 'update_teacher_info_fields' do
      learner = described_class.new
      result = learner.update_teacher_info_fields

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_permission_forms' do
    it 'update_permission_forms' do
      learner = described_class.new
      result = learner.update_permission_forms

      expect(result).not_to be_nil
    end
  end
end
