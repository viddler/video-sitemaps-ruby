$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'viddler-sitemaps'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:each) { delete_tmp_folder; ensure_tmp_folder_exists }
  config.after(:each)  { delete_tmp_folder }

  def ensure_tmp_folder_exists
    FileUtils.mkdir('spec/tmp')
  end

  def delete_tmp_folder
    FileUtils.rm_rf('spec/tmp')
  end

  def dummy_videos(number, prefix='vid')
    return [].tap do |videos|
      number.times do |n|
        videos << {'id' => "#{prefix}#{number}"}
      end
    end
  end
end
