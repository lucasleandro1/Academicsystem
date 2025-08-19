class MakeSchoolOptionalInAcademicCalendars < ActiveRecord::Migration[8.0]
  def change
    change_column_null :academic_calendars, :school_id, true
  end
end
