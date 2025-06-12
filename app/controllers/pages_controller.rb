class PagesController < ApplicationController
  before_action :authenticate_user!, only: %i[create show]
  before_action :set_page, only: %i[show index]
  before_action :set_pages, only: %i[index create]

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

  # Use callbacks to share common setup or constraints between actions.
  def set_page
    @page = if params[:id].present?
              Page.find(params[:id])
            else
              Page.new
            end
  end

  def set_pages
    @pages = user_signed_in? ? current_user.pages : Page.all
  end

  # Only allow a list of trusted parameters through.
  def create_page_params
    params.require(:page).permit(:url)
  end
end
