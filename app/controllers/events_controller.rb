class EventsController < ApplicationController
  before_action :set_event, only: [:show, :attend, :unattend, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: [:index, :new, :show, :attend, :unattend]
  before_action :authenticate_event_type!, only: [:show]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  def attend
    redirect_to toggle_attendance(current_user.id, @event.id, true, true)
  end

  def unattend
    redirect_to toggle_attendance(current_user.id, @event.id, false, true)
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
      #redirect_to modify_event_from_admin_form(params)
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        users = get_users_from_select(params['event']['users'])
        if users.blank?
          @event.errors.add(:users, "must have users!")
          format.html { render :new }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        else
          @event.users << users
          flash['success'] = t('global.model_created', type: t('global.event').downcase)
          if @event.published
            handle_notify_event(@event, true)
          end
          format.html { redirect_to @event }
          format.json { render :show, status: :created, location: @event }
        end
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        users = get_users_from_select(params['event']['users'])
        if users.blank?
          @event.errors.add(:users, "must have users!")
          format.html { render :edit }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        else
          update_event_users(users, @event)
          flash['success'] = t('global.model_modified', type: t('global.event').downcase)
          if @event.published
            handle_notify_event(@event, true)
          end
          format.html { redirect_to @event}
          format.json { render :show, status: :ok, location: @event }
        end
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    if @event.published
      handle_notify_event(@event, false)
    end
    @event.destroy
    respond_to do |format|
      flash['success'] = t('global.model_deleted', type: t('global.event').downcase)
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  def authenticate_event_type!
    if !@event.blank? && !current_user.admin && @event.message?
      flash[:error] = t('global.invalid_action')
      redirect_to root_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:title, :description, :startDate, :startTime, :endDate, :endTime, :location, :eventType, :published)
    end
end
