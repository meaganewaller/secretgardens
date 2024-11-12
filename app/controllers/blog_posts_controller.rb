class BlogPostsController < ApplicationController
  include ApplicationHelper

  before_action except: [:index, :new, :show] do
    authenticate_user!
  end
  before_action :set_blog_post, only: [:edit, :show, :update, :destroy]
  # after_action :verify_authorized
  # before_action only: [:new, :edit, :create, :update, :destroy] do
  #   authenticate_admin!(alert_message: 'You are not authorized')
  # end

  # GET /blog
  def index
    @blog_posts = BlogPost.published.order(created_at: :asc)
    # @latest = request.path == latest_feed_path
    @blog_posts = if params[:username]
                    handle_user_or_guild_feed
                  else
                    @blog_posts.includes(:user)
                  end
    @drafts = BlogPost.unpublished.order(created_at: :desc)
    not_found unless @blog_posts&.any? || @drafts&.any?
  end

  # GET /blog/:slug
  def show; end

  # GET /blog/new
  def new
    @blog_post = BlogPost.new(user: current_user)
  end

  # GET /blog/:slug/edit
  def edit; end

  # POST /blog
  def create
    @blog_post = BlogPost.new(blog_post_params)

    if @blog_post.save
      redirect_to blog_post_path(@blog_post.slug), notice: "Blog post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH /blog/:slug
  def update
    blog_post_params.merge(user_id: current_user.id)
    if @blog_post.update(blog_post_params)
      redirect_to blog_post_path(@blog_post.slug), notice: "Blog post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /blog/:slug
  def destroy
    @blog_post.destroy
    redirect_to blog_posts_url, notice: "Blog post was successfully destroyed."
  end

  private

  def set_blog_post
    owner = User.find_by(username: params[:username]) || Guild.find_by(slug: params[:username])
    found_post = if params[:slug] && owner
                   owner.blog_posts.find_by(slug: params[:slug])
                 else
                   BlogPost.includes(:user).find_by(slug: params[:slug])
                 end

    @blog_post = found_post || not_found
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :slug, :description, :body, :cover_image, :user_id, :published)
  end

  def handle_user_or_guild_feed
    if (@user = User.find_by(username: params[:username]))
      @blog_posts = @blog_posts.where(user_id: @user.id)
    elsif (@user = Guild.find_by(slug: params[:username]))
      @blog_posts = @blog_posts.where(guild_id: @user.id).includes(:user)
    end
  end
end
