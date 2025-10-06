class RecreateClassSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :class_schedules do |t|
      t.references :classroom, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.integer :weekday, null: false # 0=Domingo, 1=Segunda, ..., 6=Sábado
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.string :period # "matutino", "vespertino", "noturno"
      t.integer :class_order # 1ª aula, 2ª aula, etc.
      t.boolean :active, default: true
      t.text :notes

      t.timestamps

      # Índices para consultas eficientes
      t.index [ :classroom_id, :weekday, :start_time ], name: 'index_class_schedules_on_classroom_weekday_time'
      t.index [ :subject_id, :weekday ], name: 'index_class_schedules_on_subject_weekday'
      t.index [ :school_id, :weekday ], name: 'index_class_schedules_on_school_weekday'
    end

    # Garantir que não haja conflitos de horário na mesma sala
    add_index :class_schedules, [ :classroom_id, :weekday, :start_time, :end_time ],
              unique: true, name: 'unique_classroom_schedule'
  end
end
