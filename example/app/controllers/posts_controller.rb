class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update]

  def index
    @posts = Post.includes(comments: :author).order(created_at: :desc)
  end

  def show; end

  def new
    @post = current_user.posts.build
    build_blank_comment(@post)
    authorize @post
  end

  def create
    @post = current_user.posts.build
    authorize @post
    # expected_attributes(@post) extracts params AND filters out-of-set values
    # using the policy's expected_attribute_values_for_action.
    if @post.update(expected_attributes(@post))
      redirect_to @post, notice: "Saved. Out-of-set values were filtered by the policy."
    else
      build_blank_comment(@post)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @post
    build_blank_comment(@post)
  end

  def update
    authorize @post
    if @post.update(expected_attributes(@post))
      redirect_to @post, notice: "Saved. Out-of-set values were filtered by the policy."
    else
      build_blank_comment(@post)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  # One empty comment (with a blank author) so the nested form fields render.
  def build_blank_comment(post)
    comment = post.comments.build
    comment.build_author
  end
end
