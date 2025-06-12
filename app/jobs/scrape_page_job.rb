class ScrapePageJob < ApplicationJob
  queue_as :default

  def perform(page_id)
    page = Page.find(page_id)
    PageScrapperService.scrape_page(page)
  end
end
