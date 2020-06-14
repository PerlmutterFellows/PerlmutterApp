module EventsHelper
  def modify_event_from_admin_form(params)
    path = admin_event_new_path

    if Event.exists?(id: params['id'])
      @event = Event.where(["id = ?", params['id']]).first
    else
      @event = Event.new
    end

    @event.title = params['title']
    @event.description = params['description']
    @event.tag = params['tag']
    @event.to = params['to']
    @event.published = params['published']

    unless params['date'].blank?
      @event.date = params['date']
    end

    unless params['time'].blank?
      @event.time = params['time']
    end

    if @event.save
      # invoke publish if published
      flash[:notice] = t('events.update.success')
      path = root_path
    else
      flash[:notice] = t('global.error_message', type: "event")
    end
    path
  end
end
