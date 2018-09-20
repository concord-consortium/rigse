require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::GradeSpanExpectation do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    RiGse::GradeSpanExpectation.create!(@valid_attributes)
  end

  # TODO: auto-generated
  describe '.grade_and_domain' do # scope test
    it 'supports named scope grade_and_domain' do
      expect(described_class.limit(3).grade_and_domain('3','2')).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#domain' do
    it 'domain' do
      grade_span_expectation = described_class.new
      result = grade_span_expectation.domain

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.grade_spans' do
    it 'grade_spans' do
      result = described_class.grade_spans

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.default_grade_span' do
    it 'default_grade_span' do
      result = described_class.default_grade_span

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.default' do
    it 'default' do
      FactoryBot.create :rigse_grade_span_expectation, grade_span: '9-11'
      result = described_class.default

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#description' do
    xit 'description' do
      grade_span_expectation = described_class.new
      result = grade_span_expectation.description

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#summary_data' do
    it 'summary_data' do
      grade_span_expectation = described_class.new
      result = grade_span_expectation.summary_data

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#print_summary_data' do
    it 'print_summary_data' do
      grade_span_expectation = described_class.new
      stem_format = double('stem_format')
      indicators_format = double('indicators_format')
      result = grade_span_expectation.print_summary_data(stem_format, indicators_format)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#theme_keys' do
    xit 'theme_keys' do
      grade_span_expectation = described_class.new
      result = grade_span_expectation.theme_keys

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_gse_key' do
    xit 'set_gse_key' do
      grade_span_expectation = described_class.new
      result = grade_span_expectation.set_gse_key

      expect(result).not_to be_nil
    end
  end


end
