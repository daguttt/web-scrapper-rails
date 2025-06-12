require 'rails_helper'

RSpec.describe PageScrapperService do
  let(:page) { create(:page, url: 'https://nokogiri.org/rdoc/index.html') }

  describe '#run' do
    context 'when page can be scraped' do
      before { PageScrapperService.run(page) }

      it 'returns success', vcr: { cassette_name: 'nokogiri.org' } do
        result = PageScrapperService.run(page)
        expect(result).to be_success
      end

      it 'updates the page title', vcr: { cassette_name: 'nokogiri.org' } do
        expect(page.reload.title).to eq('RDoc Documentation')
      end

      it 'adds links to the page', vcr: { cassette_name: 'nokogiri.org' } do
        expect(page.reload.links.count).to be 193
      end
    end

    context 'when the page cannot be scraped' do
      before do
        page.update(url: 'https://stackoverflow.com/questions/9603321/rails-switch-case-in-the-view')
      end

      it 'returns failure' do
        result = PageScrapperService.run(page)
        expect(result).to be_failure
      end

      it 'updates the page status to failed' do
        PageScrapperService.run(page)
        expect(page.reload.status).to eq('failed')
      end
    end
  end
end
