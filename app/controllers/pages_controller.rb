class PagesController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!, only: %i[create show]
  before_action :set_page, only: %i[show]
  before_action :set_pages, only: %i[index]

  # GET /pages or /pages.json
  def index
    @page = Page.new
  end

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
    raise ActiveRecord::ActiveRecordError if params[:id].present? && !user_signed_in?

    @page = current_user.pages.find(params[:id])
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
