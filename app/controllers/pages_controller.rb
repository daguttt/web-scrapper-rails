class PagesController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!, only: %i[create show]
  # Also in `index` action for the new page field
  before_action :set_page, only: %i[show index]
  before_action :set_pages, only: %i[index]

  # GET /pages or /pages.json
  def index; end

  # GET /pages/1 or /pages/1.json
  def show; end

  # POST /pages
  def create
    @page = Page.new(create_page_params)
    @page.user = current_user

    respond_to do |format|
      if @page.save
        format.html { redirect_to pages_path, notice: t('.success') }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_page
    @page = if params[:id].present?
              Page.find(params[:id])
            else
              Page.new
            end
    @pagy, @page_links = pagy(@page.links)
  end

  def set_pages
    return @pagy = nil, @pages = [] unless user_signed_in?

    @pagy, @pages = pagy(current_user.pages)
  end

  # Only allow a list of trusted parameters through.
  def create_page_params
    params.require(:page).permit(:url)
  end
end
