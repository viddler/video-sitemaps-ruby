require 'spec_helper'

describe Viddler::Sitemap do
  before(:each) do
    Viddler::Client.any_instance.stub(:authenticate!).with('myusername', 'mypassword')
  end

  describe '#setup_client' do
    it 'should setup a Vidder::Client object using the API key' do
      Viddler::Client.any_instance.should_receive(:authenticate!).with('myusername', 'mypassword')
      @sitemap = Viddler::Sitemap.new('myapikey', 'myusername', 'mypassword')

      client = @sitemap.instance_variable_get('@client')
      client.should be_a(Viddler::Client)
      client.api_key.should == 'myapikey'
    end
  end

  describe '#each_video' do
    it 'should include an array of all videos, calling the API for each page until all retrieved' do
      @sitemap = Viddler::Sitemap.new('myapikey', 'myusername', 'mypassword')
      client = @sitemap.instance_variable_get('@client')

      client.should_receive(:get).with('viddler.videos.getByUser', hash_including(:user => 'myusername', :page => 1))
                                 .and_return({'list_result' => {'video_list' => dummy_videos(100, 'page1')}})
      client.should_receive(:get).with('viddler.videos.getByUser', hash_including(:user => 'myusername', :page => 2))
                                 .and_return({'list_result' => {'video_list' => dummy_videos(100, 'page2')}})
      client.should_receive(:get).with('viddler.videos.getByUser', hash_including(:user => 'myusername', :page => 3))
                                 .and_return({'list_result' => {'video_list' => dummy_videos(50, 'page3')}})

      client.should_not_receive(:get).with('viddler.videos.getByUser', hash_including(:user => 'myusername', :page => 4))

      videos = []
      @sitemap.each_video { |v| videos << v }
      videos.length.should == 250
    end
  end

  describe '#files' do
    before(:each) do
      setup_big_sitemap
      Viddler::Sitemap.max_videos_per_file = 50
    end

    it 'should return an array of SiteMapFile objects' do
      @sitemap.files.length.should == 3
    end

    it 'should assign a maximum of 50 videos per file' do
      @sitemap.files[0].videos.length.should == 50
      @sitemap.files[1].videos.length.should == 50
      @sitemap.files[2].videos.length.should == 10
    end
  end

  describe '#generate!' do
    before(:each) do
      setup_big_sitemap
      Viddler::Sitemap.max_videos_per_file = 50
      @path = File.dirname(__FILE__) + '/tmp'
    end

    it 'should return the total number of videos indexed' do
      @sitemap.generate!(@path).should == 110
    end

    it 'should write the sitemaps to the specified directory' do
      @sitemap.generate!(@path)
      File.exists?('spec/tmp/sitemap-1.xml').should == true
      File.exists?('spec/tmp/sitemap-2.xml').should == true
      File.exists?('spec/tmp/sitemap-3.xml').should == true
      File.exists?('spec/tmp/sitemap-4.xml').should == false
    end
  end

  def setup_big_sitemap
    @sitemap = Viddler::Sitemap.new('myapikey', 'myusername', 'mypassword')

    # Fake it so that it looks like the user has 110,000 vides
    @sitemap.stub!(:videos_for_page).with(1).and_return(dummy_videos 110)
    @sitemap.stub!(:videos_for_page).with(2).and_return([])
  end
end
