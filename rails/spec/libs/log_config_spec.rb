require File.expand_path('../../spec_helper', __FILE__)

describe LogConfig do
  before(:each) do
    # Force STDOUT logging for newly created logs
    allow(BoolEnv).to receive(:[]).with("RAILS_STDOUT_LOGGING").and_return(true)
  end

  describe 'configure' do
    let(:valid_levels) { LogConfig::AVAILABLE_LOG_LEVELS }
    let(:invalid_levels) { ['frog', 0, nil, '', ' '] }
    let(:config) { OpenStruct.new }

    describe 'With valid default log level' do
      describe 'with valid log levels' do
        it 'should return a Log with the correct log level configured' do
          valid_levels.each_with_index do |level, level_index|
            LogConfig.configure(config, level, 'INFO')
            expect(config.logger.level).to eq(level_index)
            expect(config.log_level).to eq(level)
          end
        end
      end

      describe 'With invalid log levels' do
        it 'should return the default specified' do
          invalid_levels.each do |level|
            LogConfig.configure(config, level, 'INFO')
            expect(config.logger.level).to eq(1)
            expect(config.log_level).to eq('INFO')
          end
        end
      end
    end

    describe 'With invalid default and specd levels' do
      it 'should use the most verbose log level available (DEBUG)' do
        LogConfig.configure(config, nil, nil)
        expect(config.logger.level).to eq(0)
        expect(config.log_level).to eq(valid_levels[0])
        expect(config.log_level).to eq('DEBUG')
      end
    end
  end
end
