# frozen_string_literal: false

require 'spec_helper'


RSpec.describe InstallerReport, type: :model do

  let(:installer_report) { described_class.new(body: 'body') }
  
  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    it 'name' do
      result = installer_report.name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#changeable?' do
    it 'changeable?' do
      something = double('something')
      result = installer_report.changeable?(something)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#cache_dir' do
    it 'cache_dir' do
      
      result = installer_report.cache_dir

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#saved_jar' do
    it 'saved_jar' do
      
      result = installer_report.saved_jar

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#local_socket_address' do
    it 'local_socket_address' do
      
      result = installer_report.local_socket_address

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#local_host_address' do
    it 'local_host_address' do
      
      result = installer_report.local_host_address

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#os' do
    it 'os' do
      result = installer_report.os

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#java' do
    it 'java' do
      
      result = installer_report.java

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#using_temp_dir?' do
    it 'using_temp_dir?' do
      
      result = installer_report.using_temp_dir?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#already_existed?' do
    it 'already_existed?' do
      
      result = installer_report.already_existed?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#learner_id' do
    it 'learner_id' do
      
      result = installer_report.learner_id

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#learner' do
    it 'learner' do
      
      result = installer_report.learner

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#local_user' do
    it 'local_user' do
      
      result = installer_report.local_user

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#install_level' do
    it 'install_level' do
      
      result = installer_report.install_level

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#find' do
    it 'find' do
      regexp = 'regexp'
      result = installer_report.find(regexp)

      expect(result).to be_nil
    end
  end

end
