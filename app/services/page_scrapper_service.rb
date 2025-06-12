class PageScrapperService
  class CouldNotFetchPageError < StandardError
    attr_reader :url, :status_code

    def initialize(message, url: nil, status_code: nil)
      super(message) # Pass the main message to StandardError's initialize
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
    Result.failure(CouldNotFetchPageError.new(e.message, url: url, status_code: response.status))
  end

  def self.compute_link_url(link_url:, base_url:)
    return link_url if link_url.start_with?('http')

    parsed_base_url = base_url.sub(/#.*/, '')
                        .sub(%r{/$}, '')
    "#{parsed_base_url}/#{link_url}"
  end

  def self.scrape_page_links(doc:, base_url:)
    doc.css('a[href]').map do |link|
      Link.new(
        url: compute_link_url(link_url: link['href'], base_url: base_url),
        title: extract_link_title(link)
      )
    end
  end

  def self.extract_link_title(link)
    text = link.text.strip
    text.presence || link.inner_html.truncate(50)
  end

  def self.extract_page_title(doc:)
    doc.css('title').text.strip
  end

  def update_page_title(page_obj:, doc:)
    page_title = extract_page_title(doc:)
    Rails.logger.debug { "Page title: #{page_title}" } if Rails.logger.debug?
    Result.success page_obj.update!(title: page_title)
  rescue ActiveRecord::ActiveRecordError => e
    handle_error(error: e, page_obj:)
  end

  def update_page_links(page_obj:, doc:)
    links = scrape_page_links(doc:, base_url: page_obj.url)
    Rails.logger.debug { "Links count: #{links.count}" } if Rails.logger.debug?
    page_obj.links = links
    Result.success page_obj.save!
  rescue ActiveRecord::ActiveRecordError => e
    handle_error(error: e, page_obj:)
  end

  def self.scrape_page(page_obj)
    html_result = fetch_page_html(url: page_obj.url)
    return handle_error(error: html_result.error, page_obj:) if html_result.failure?

    doc = Nokogiri::HTML(html_result.value)
    update_page_title(page_obj:, doc:)
    update_page_links(page_obj:, doc:)

    page_obj.update(status: :success)
    Result.success('Page successfully scraped')
  end

  def handle_error(error:, page_obj:)
    page_obj.update(status: :failed)

    # TODO: Send error to loggin service
    case error
    when CouldNotFetchPageError
      Rails.logger.error do
        "Error fetching page's html (URL: #{error.url}, Status code: #{error.status_code}). Error Message: #{error.message} "
      end
    when ActiveRecord::ActiveRecordError
      Rails.logger.error { "Error updating page in DB: #{error.message}" }
    end
    Result.failure(error)
  end
end
