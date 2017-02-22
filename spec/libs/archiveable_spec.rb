require 'spec_helper'

class WithoutArchiveFields
  include Archiveable
end

class WithArchiveFields
  include Archiveable
  attr_accessor :is_archived
  attr_accessor :archive_date
  def update_attributes(hash_data)
    hash_data.each do |k,v|
      self.send("#{k}=".to_sym,v)
    end
  end
end

describe Archiveable do
  let(:undertest) { WithoutArchiveFields }
  let(:instance)  { undertest.new }

  describe "A class that doesn't respond to is_archived" do
    describe "archived?" do
      it "should return false" do
        expect(instance.archived?).to be_falsey
      end
    end
    describe "archive!" do
      it "should throw an exception" do
        expect { instance.archive!}.to raise_error(RuntimeError)
      end
    end

    describe "unarchive!" do
      it "should throw an exception" do
        expect { instance.unarchive!}.to raise_error(RuntimeError)
      end
    end
  end
  
  describe "A class that  responds to is_archived and is_archived=" do
    let(:undertest) { WithArchiveFields }
    describe "archived?" do
      it "should return its own values" do
        instance.is_archived = true
        expect(instance.archived?).to be_truthy
        instance.is_archived = false
        expect(instance.archived?).to be_falsey
      end
    end
    describe "archive!" do
      it "should set the archive status to true" do
        instance.is_archived = false
        instance.archive!
        expect(instance.archived?).to be_truthy
      end
    end

    describe "unarchive!" do
      it "should set the archive status to false" do
        instance.is_archived = true
        instance.unarchive!
        expect(instance.archived?).to be_falsey
      end
    end
  end

end