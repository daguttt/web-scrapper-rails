class Page < ApplicationRecord
  # Associations
  has_many :links, dependent: :destroy

  # Attributes
  enum :status, { processing: 0, success: 1, failed: 2 }
  attribute :status, default: :processing

  # Validations
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }

  # Callbacks
  after_create :scrape_page

  private

  def scrape_page
    ScrapePageJob.perform_later(id)
  end
end
