require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Parser do
  before(:all) do
    @parser = Parser.new
    @parser.process_rigse_data
    @domains = Domain.find(:all)
    @knowledge_statements = KnowledgeStatement.find(:all)
  end

  it "should create domains that have names" do
    @domains.each do |d|
      d.name.should_not be_empty
    end
  end

  it "should create domains that have keys" do
    @domains.each do |d|
      d.key.should_not be_empty
    end
  end

  it "should create knowledge statements that have numbers" do
    @knowledge_statements.each do |ks|
      ks.number.should be_a_kind_of(Fixnum)
    end
  end

  it "should create knowledge statements that have descriptions" do
    @knowledge_statements.each do |ks|
      ks.description.should_not be_empty
    end
  end

  it "should create knowledge statements that have domains" do
    @knowledge_statements.each do |ks|
      ks.domain.should be_a_kind_of(Domain)
    end
  end

end
