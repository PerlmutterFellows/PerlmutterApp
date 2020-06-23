class DateService
  def convert_to_readable_date(date)
    date.strftime("%A, %B %e, %Y")
  end
  def convert_to_readable_time(time)
    time.strftime("%I:%M %p")
  end
  def convert_to_readable_date_time(date, time)
    if !date.blank? || !time.blank?
      if !date.blank? && !time.blank?
        "#{DateService.new.convert_to_readable_date(date)} #{DateService.new.convert_to_readable_time(time)}"
      elsif !date.blank? && time.blank?
        "#{DateService.new.convert_to_readable_date(date)}"
      else
        "#{DateService.new.convert_to_readable_time(time)}"
      end
    else
      ""
    end
  end
end
