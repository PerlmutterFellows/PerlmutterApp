class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_moderator!, only: [:index, :show, :new, :edit, :create, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new({name: params['group']['name']})

    respond_to do |format|
      users = get_users_from_select(params['group']['users'])
      unless users.blank?
        @group.users = users
      end
      if @group.save
        flash.notice = t('global.model_created', type: t('global.group').downcase)
        format.html { redirect_to @group }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      @group.users.clear
      users = get_users_from_select(params['group']['users'])
      unless users.blank?
        @group.users = users
      end
      if @group.update({name: params['group']['name']})
          flash.notice = t('global.model_modified', type: t('global.group').downcase)
          format.html { redirect_to @group }
          format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      flash.notice = t('global.model_deleted', type: t('global.group').downcase)
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name, :users)
    end
end
