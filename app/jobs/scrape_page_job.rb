class ScrapePageJob < ApplicationJob
  queue_as :default

  def perform(page_id)
    page = Page.find(page_id)
    PageScrapperService.run(page)
  end
end
