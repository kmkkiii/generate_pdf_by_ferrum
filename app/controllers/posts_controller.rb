class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy download_pdf ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  def download_pdf
    html = render_to_string(template: 'posts/_post', layout: 'pdf', locals: { post: @post })
    pdf = html2pdf(html)
    send_data pdf, filename: "post_#{@post.id}.pdf", type: 'application/pdf'
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :published)
    end

    def html2pdf(html)
      browser = Ferrum::Browser.new(browser_path: '/usr/bin/chromium', browser_options: { 'no-sandbox': nil })
      header_html = render_to_string('pdf/header', layout: false)
      footer_html = render_to_string('pdf/footer', layout: false)
      browser.goto("data:text/html,#{html}")
      pdf = browser.pdf(
        format: :A4,
        encoding: :binary,
        display_header_footer: true,
        header_template: header_html,
        footer_template: footer_html,
      )
      browser.quit
      pdf
    end
end
