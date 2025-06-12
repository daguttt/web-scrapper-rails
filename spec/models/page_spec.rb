require 'rails_helper'

RSpec.describe Page, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:links).dependent(:destroy) }
  end

  describe 'validations' do
    context 'when validating url format' do
      it { is_expected.to validate_presence_of(:url) }

      it 'is valid page' do
        valid_page = build(:page, url: 'https://example.com')

        expect(valid_page).to be_valid
      end

      it 'is invalid page' do
        invalid_page = build(:page, url: 'not_a_url')
        expect(invalid_page).not_to be_valid
      end
    end
  end

  describe 'callbacks' do
    it 'enqueues ScrapePageJob after creation' do
      ActiveJob::Base.queue_adapter = :test

      page = create(:page)
      expect(ScrapePageJob).to have_been_enqueued.with(page.id)
    end
  end
end
