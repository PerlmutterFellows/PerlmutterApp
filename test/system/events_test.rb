require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @event = events(:one)
  end

  test "visiting the index" do
    visit events_url
    assert_selector "h1", text: "Events"
  end

  test "creating a Event" do
    visit events_url
    click_on "New Event"

    fill_in "Description", with: @event.description
    fill_in "Enddate", with: @event.endDate
    fill_in "Endtime", with: @event.endTime
    fill_in "Eventtype", with: @event.eventType
    fill_in "Location", with: @event.location
    check "Published" if @event.published
    fill_in "Startdate", with: @event.startDate
    fill_in "Starttime", with: @event.startTime
    fill_in "Title", with: @event.title
    fill_in "To", with: @event.to
    click_on "Create Event"

    assert_text "Event was successfully created"
    click_on "Back"
  end

  test "updating a Event" do
    visit events_url
    click_on "Edit", match: :first

    fill_in "Description", with: @event.description
    fill_in "Enddate", with: @event.endDate
    fill_in "Endtime", with: @event.endTime
    fill_in "Eventtype", with: @event.eventType
    fill_in "Location", with: @event.location
    check "Published" if @event.published
    fill_in "Startdate", with: @event.startDate
    fill_in "Starttime", with: @event.startTime
    fill_in "Title", with: @event.title
    fill_in "To", with: @event.to
    click_on "Update Event"

    assert_text "Event was successfully updated"
    click_on "Back"
  end

  test "destroying a Event" do
    visit events_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Event was successfully destroyed"
  end
end
