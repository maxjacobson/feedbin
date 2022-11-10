require "test_helper"
module ImageCrawler
  class UploadImageTest < ActiveSupport::TestCase
    def setup
      flush_redis
    end

    def test_should_upload
      public_id = SecureRandom.hex
      path = copy_support_file("image.jpeg")
      url = "http://example.com/image.jpg"
      placeholder_color = "0867e2"

      stub_request(:put, /s3\.amazonaws\.com/)

      assert_difference -> { EntryImage.jobs.size }, +1 do
        UploadImage.new.perform(public_id, "primary", path, url, url, placeholder_color)
      end

      saved_public_id, options = EntryImage.jobs.last.dig("args")

      download_cache = DownloadCache.new(url, public_id: public_id, preset_name: "primary")
      assert_equal(url, download_cache.image_url)
      assert_equal("https:", download_cache.storage_url)
      assert_equal(placeholder_color, download_cache.placeholder_color)
      assert_equal(public_id, saved_public_id)
      assert_equal(url, options["original_url"])
      assert_equal("https:", options["processed_url"])
    end
  end
end