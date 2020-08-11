class EventReflex < ApplicationReflex
  def toggle_attending
    event_status = EventStatus.find_by(event_id: element.dataset[:event_id], user_id: element.dataset[:user_id])
    if event_status.not_attending?
      event_status.attending!
    elsif event_status.attending?
      event_status.not_attending!
    end
  end
end
