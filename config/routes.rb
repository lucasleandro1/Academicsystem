Rails.application.routes.draw do
  devise_for :users
  root "application#dashboard"

  resources :messages, except: [ :edit, :update ]
  resources :notifications, only: [ :index, :show, :destroy ] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
      delete :clear_all
    end
  end

  # Calendário acadêmico (visualização para todos os usuários)
  resources :calendars, only: [ :index ]

  namespace :admin do
    resources :schools
    resources :users
    resources :directions, except: [ :show, :edit, :update ]
    resources :events
    resources :documents do
      member do
        get :download
      end
    end
    resources :messages, only: [ :index, :new, :create, :show ] do
      collection do
        post :broadcast_to_all_schools
        post :broadcast_to_all_directors
        post :broadcast_to_all_teachers
        post :broadcast_to_all_students
        post :broadcast_to_school
      end
    end
    resources :reports, only: [ :index ] do
      collection do
        get :municipal_overview
        get :attendance_report
        get :performance_report
        get :student_distribution
        get :evasion_report
        get :export_pdf
        get :export_excel
      end
    end
    resources :calendars do
      collection do
        get :municipal
      end
    end
    resources :settings, only: [ :index ] do
      collection do
        patch :update_academic_calendar
        get :manage_permissions
        patch :update_user_permissions
        patch :reset_user_access
        post :backup_system
        get :system_info
        get :security_settings
      end
    end
    root to: "dashboard#index"
  end

  namespace :direction do
    resource :school, only: [ :show, :edit, :update ]
    resources :teachers
    resources :students
    resources :classrooms do
      member do
        patch :add_student
        patch :remove_student
      end
    end
    resources :subjects
    resources :events
    resources :calendars, only: [ :index ]
    resources :reports, only: [ :index, :show ] do
      collection do
        get :generate_pdf
        get :attendance_report
        get :grades_report
        get :student_bulletin
        get :performance_stats
        get :disciplinary_report
      end
    end
    resources :documents do
      member do
        get :download
      end
      collection do
        get "attach_to_user/:user_id", to: "documents#attach_to_user", as: "attach_to_user"
      end
    end
    resources :class_schedules
    resources :messages, only: [ :index, :new, :create, :show ] do
      collection do
        post :broadcast_to_all
        post :broadcast_to_directions
        post :broadcast_to_teachers
        post :broadcast_to_students
        post :broadcast_to_classroom
      end
    end
    root to: "dashboard#index"

    # Dashboard refresh route
    get "dashboard/refresh_data", to: "dashboard#refresh_data"
  end

  namespace :teachers do
    resources :classrooms, only: [ :index, :show ]
    resources :grades do
      collection do
        get :get_classrooms
        get :get_students
      end
    end
    resources :absences do
      collection do
        get :attendance
        post :bulk_create
        get :get_classrooms
        get :get_students
      end
    end
    resources :subjects, only: [ :index, :show ] do
      resources :class_schedules, only: [ :index, :show ]
    end
    resources :class_schedules, only: [ :index, :show ]
    resources :calendars, only: [ :index ]
    resources :events, only: [ :index, :show ]
    resources :documents do
      member do
        get :download
      end
      collection do
        get "attach_to_student/:student_id", to: "documents#attach_to_student", as: "attach_to_student"
      end
    end
    resources :messages, only: [ :index, :new, :create, :show ] do
      collection do
        post :send_to_student
        post :send_to_classroom
        post :send_to_direction
      end
    end
    resources :reports, only: [ :index ] do
      collection do
        get :student_performance
        get :classroom_attendance
        get :grade_summary
        get :export_pdf
      end
    end
    root to: "dashboard#index"
  end

  namespace :students do
    resource :profile, only: [ :show, :edit, :update ]
    resources :grades, only: [ :index ]
    resources :subjects, only: [ :index, :show ]
    resources :absences, only: [ :index ]
    resources :class_schedules, only: [ :index ]
    resources :calendars, only: [ :index ]
    resources :documents do
      member do
        get :download
      end
      collection do
        get :generate_report_card
      end
    end
    resources :events, only: [ :index, :show ]
    resources :messages, only: [ :index, :new, :create, :show, :destroy ]
    root to: "dashboard#index"
  end
end
