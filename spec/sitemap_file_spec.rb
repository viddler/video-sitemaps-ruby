require 'spec_helper'

describe Viddler::SitemapFile do
  describe '#to_xml' do
    it 'should render the xml for the videos in the sitemap file' do
      video_1 = {
        'id' => '182d7551',
        'status' => 'ready',
        'author' => 'mattfawcett',
        'title' => 'vid8',
        'length' => '96',
        'description' => 'Some  <b>Strong</b> Description \n \n a new line',
        'age_limit' => '',
        'url' => 'http://www.viddler.com/v/182d7551',
        'thumbnail_url' => 'http://cdn-thumbs.viddler.com/thumbnail_2_182d7551_v1.jpg',
        'permalink' => 'http://www.viddler.com/v/182d7551',
        'html5_video_source' => 'http://www.viddler.com/file/182d7551/html5',
        'view_count' => '0',
        'impression_count' => '0',
        'upload_time' => '1337945626',
        'made_public_time' => '1337946278',
        'favorite' => '0',
        'comment_count' => '0',
        'display_aspect_ratio' => '4:3'
      }
      video_2 = {
        'id' => '7e6eba64',
        'status' => 'ready',
        'author' => 'mattfawcett',
        'title' => 'vid9',
        'length' => '96',
        'description' => 'A description goes here',
        'age_limit' => '',
        'url' => 'http://www.viddler.com/v/7e6eba64',
        'thumbnail_url' => 'http://cdn-thumbs.viddler.com/thumbnail_2_7e6eba64_v1.jpg',
        'permalink' => 'http://www.viddler.com/v/7e6eba64',
        'html5_video_source' => 'http://www.viddler.com/file/7e6eba64/html5',
        'view_count' => '0',
        'impression_count' => '0',
        'upload_time' => '1337945626',
        'made_public_time' => '1337946278',
        'favorite' => '0',
        'comment_count' => '0',
        'display_aspect_ratio' => '4:3'
      }
      sitemap_file = Viddler::SitemapFile.new
      sitemap_file.add_video(video_1)
      sitemap_file.add_video(video_2)

      expected = File.read('spec/data/simple_sitemap.xml')
      sitemap_file.to_xml.should == expected
    end
  end

  describe '#write!' do
    it 'should write the contents to the correct place' do
      sitemap_file = Viddler::SitemapFile.new
      sitemap_file.should_receive(:to_xml).and_return('dummy xml')
      sitemap_file.write!(File.dirname(__FILE__) + '/tmp', 2)
      File.read('spec/tmp/sitemap-2.xml').should == 'dummy xml'
    end
  end
end
