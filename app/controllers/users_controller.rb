# Controller for the User model.
class UsersController < ApplicationController
  before_action :set_user, only: %i[show destroy]

  # GET /users or /users.json
  def index
    @users = UserDetail.all
  end

  # GET /users/1 or /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users or /users.json
  def create
    if create_user
      redirect_to user_url(@user), notice: 'User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.includes(:languages, repositories: :language).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name)
  end

  def create_user
    @user = User.new(user_params)
    return false unless @user.save

    GithubImport.new.update_user(@user)
    UserDetail.refresh
    true
  end
end
