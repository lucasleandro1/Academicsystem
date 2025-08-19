class RenameAcademicCalendarsToCalendars < ActiveRecord::Migration[8.0]
  def change
    rename_table :academic_calendars, :calendars
  end
end
