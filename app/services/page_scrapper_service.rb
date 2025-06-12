class PageScrapperService
  class CouldNotFetchPageError < StandardError
    attr_reader :url, :status_code

    def initialize(message, url: nil, status_code: nil)
      super(message)
      @url = url
      @status_code = status_code
    end
  end

  def self.fetch_page_html(url:)
    conn = Faraday.new(url:) do |faraday|
      faraday.response :raise_error # raise Faraday::Error on status code 4xx or 5xx
    end
    response = conn.get(url)

    Result.success response.body
  rescue Faraday::Error => e
    Result.failure(CouldNotFetchPageError.new(e.message, url: url, status_code: e.response[:status]))
  end

  def self.compute_link_url(link_url:, base_url:)
    return link_url if link_url.start_with?('http')

    parsed_base_url = URI.parse(base_url)
    URI.join(parsed_base_url.origin, link_url)
  end

  def self.scrape_page_links(doc:, base_url:)
    links = doc.css('a[href]').map do |link|
      Link.new(
        url: compute_link_url(link_url: link['href'], base_url: base_url),
        title: extract_link_title(link)
      )
    end
    Rails.logger.debug { "Links count: #{links.count}" } if Rails.logger.debug?
    links
  end

  def self.extract_link_title(link)
    text = link.text.strip
    text.presence || link.inner_html.truncate(50)
  end

  def self.extract_page_title(doc:)
    page_title = doc.css('title').text.strip
    Rails.logger.debug { "Page title: #{page_title}" } if Rails.logger.debug?
    page_title
  end

  def self.scrape_page(html:, base_url:)
    Rails.logger.debug { "Scraping page: #{base_url}" } if Rails.logger.debug?

    doc = Nokogiri::HTML(html)
    page_title = extract_page_title(doc:)
    links = scrape_page_links(doc:, base_url:)

    {
      links:,
      page_title:
    }
  end

  def self.run(page_obj)
    html_result = fetch_page_html(url: page_obj.url)
    return handle_error(error: html_result.error, page_obj:) if html_result.failure?

    links, page_title = scrape_page(html: html_result.value, base_url: page_obj.url).fetch_values(:links, :page_title)

    page_obj.links = links
    page_obj.title = page_title
    page_obj.update!(status: :success)
    Result.success('Page successfully scraped')
  rescue ActiveRecord::ActiveRecordError => e
    handle_error(error: e, page_obj:)
  end

  def self.handle_error(error:, page_obj:)
    page_obj.update(status: :failed)

    case error
    when CouldNotFetchPageError
      Rails.logger.error do
        <<~ERROR
          Error fetching page's html (URL: #{error.url}, Status code: #{error.status_code}).
          Error Message: #{error.message}
        ERROR
      end
    when ActiveRecord::ActiveRecordError
      Rails.logger.error { "Error updating page in DB: #{error.message}" }
    end
    Result.failure(error)
  end
end
