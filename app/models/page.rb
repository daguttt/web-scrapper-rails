class Page < ApplicationRecord
  enum :status, { processing: 0, success: 1, failed: 2 }

  attribute :status, default: :processing

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
end
