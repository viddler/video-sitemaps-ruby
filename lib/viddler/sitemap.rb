module Viddler
  class Sitemap
    API_PER_PAGE = 100

    # Setup a new instance of Viddler Sitemap
    # @param [String] api_key Viddler API key
    # @param [String] username Viddler username
    # @param [String] password Viddler password
    def initialize(api_key, username, password)
      @api_key, @username, @password = api_key, username, password
      setup_client
    end

    # Generate the sitemap files(s) for your videos
    #
    # @param [String] folder The path to the folder where the sitemap files will be written to
    # @return [Integer] the number of videos that were included in the index
    def generate!(folder)
      counter = 0
      files.each_with_index do |file, index|
        counter += file.videos.length
        file.write!(folder, index+1)
      end
      return counter
    end

    # @return [Array] An array of SitemapFile objects each representing 1 sitemap file.
    #   There will normally be only 1 of these but could be more if there are lots of videos.
    #   There are a maxiumum of 5000 (default) videos per file.
    def files
      [].tap do |array|
        array << SitemapFile.new
        counter = 0
        each_video do |video|
          counter += 1

          # Add the video to the current file
          array.last.add_video(video)

          # Reached 50k in this file, start a new file
          array << SitemapFile.new if counter % Sitemap.max_videos_per_file == 0
        end
      end
    end

    # Yields each video that will be included in the sitemap
    def each_video(&block)
      page = 1
      loop do
        videos = videos_for_page(page)
        videos.each { |v| yield v }

        break if videos.length < API_PER_PAGE
        page += 1
      end
    end

    # The maximum number of videos to be incuded in each sitemap file.
    # @return [Integer] the maximum number. Defaults to 50000
    def self.max_videos_per_file
      @@max_videos_per_file ||= 50000
    end

    # Set the maximum number of videos that should be included in one sitemap file.
    # Defaults to 50000 which is Google's maximum. You may want to lower this on systems
    # with limited resources
    # @param [Integer] value The maximum number
    def self.max_videos_per_file=(value)
      @@max_videos_per_file = value
    end

    private
    # An authenticated instance of the API client
    # @return [Viddler::Client]
    def setup_client
      @client = Viddler::Client.new(@api_key)
      @client.authenticate!(@username, @password)
    end

    # Calls the API to return an array of videos for a certain page. The API will return a maximum
    # of 100 pages per request
    def videos_for_page(page_number)
      @client.get('viddler.videos.getByUser', :user => @username, :per_page => API_PER_PAGE,
                                              :page => page_number, :visibility => 'public,embed')['list_result']['video_list']
    end
  end
end
