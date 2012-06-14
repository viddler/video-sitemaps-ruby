module Viddler
  class SitemapFile
    # An array of video hash object that will be included in the SitemapFile
    attr_reader :videos

    def initialize
      @videos = []
    end

    # Add a video to this sitemap file
    # @param [Hash] video the video details hash from the API response
    def add_video(video)
      @videos << video
      return true
    end

    # The XML string for this SitemapFile
    # @return [String] the XML
    def to_xml
      @builder = Builder::XmlMarkup.new(:indent => 2)
      @builder.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')

      @builder.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
                      'xmlns:video' => 'http://www.google.com/schemas/sitemap-video/1.1') do | xml|
        @videos.each do |video|
          downloadable = video['permissions'] && video['permissions']['download'] != 'private'
          embedable    = video['permissions'] && video['permissions']['embed'] != 'private'

          xml.url do |xml|
            xml.loc(video['permalink'])
            xml.tag!('video:video') do
              xml.tag!('video:thumbnail_loc', "http://www.viddler.com/thumbnail/#{video['id']}")
              xml.tag!('video:title', video['title'])
              xml.tag!('video:description', video['description'])
              if downloadable
                xml.tag!('video:content_loc', video['files'].first['url'])
              end
              xml.tag!('video:player_loc', "http://www.viddler.com/embed/#{video['id']}", :allow_embed => embedable ? 'yes' : 'no')
              xml.tag!('video:duration', video['length'])
              xml.tag!('video:view_count', video['view_count'])
              xml.tag!('video:publication_date', Time.at(video['upload_time'].to_i).strftime('%Y-%m-%d'))
              xml.tag!('video:family_friendly', 'yes')
              xml.tag!('video:live', 'no')
            end
          end
        end
      end
      return @builder.target!
    end

    # Write the xml content for this SitemapFile to disk
    # @param [String] folder The path to the folder where the sitemaps should be written
    # @param [Integer] file_number The number of this file. Because there is a maximum number of videos per file, there may be multiple files.
    def write!(folder, file_number)
      path = "#{folder}/sitemap-#{file_number}.xml"
      File.open(path, 'w') { |f| f.write(self.to_xml) }
    end
  end
end

