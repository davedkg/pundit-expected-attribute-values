# Vanilla session-based "sign in as" — no passwords, no Devise. Pick one of the
# seeded users to act as, then sign out to choose another.
class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    @users = User.order(:role, :name)
  end

  def create
    user = User.find(params[:user_id])
    session[:user_id] = user.id
    redirect_to posts_path, notice: "Signed in as #{user.name} (#{user.role})."
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out."
  end
end
