Rails.application.routes.draw do
  devise_for :users
  root "application#dashboard"

  # Mensagens (disponível para todos os usuários logados)
  resources :messages, except: [ :edit, :update ]

  namespace :admin do
    resources :schools
    resources :users
    resources :directions, except: [ :show, :edit, :update ]
    resources :reports, only: [ :index ]
    root to: "dashboard#index"
  end

  namespace :direction do
    resource :school, only: [ :show, :edit, :update ]
    resources :teachers
    resources :students
    resources :classrooms do
      resources :enrollments, except: [ :new, :create, :edit, :update ]
    end
    resources :subjects
    resources :enrollments do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :events
    resources :occurrences
    resources :reports, only: [ :index, :show ] do
      collection do
        get :generate_pdf
      end
    end
    resources :documents
    resources :class_schedules
    root to: "dashboard#index"
  end

  namespace :teachers do
    resources :classrooms, only: [ :index, :show ]
    resources :activities do
      resources :submissions, only: [ :index, :show, :edit, :update ]
    end
    resources :grades
    resources :absences
    resources :occurrences
    resources :subjects, only: [ :index, :show ]
    resources :class_schedules, only: [ :index, :show ]
    resources :submissions, only: [ :index, :show, :edit, :update ]
    root to: "dashboard#index"
  end

  namespace :students do
    resource :profile, only: [ :show, :edit, :update ]
    resources :grades, only: [ :index ]
    resources :subjects, only: [ :index, :show ]
    resources :activities, only: [ :index, :show ] do
      resources :submissions, except: [ :index ]
    end
    resources :absences, only: [ :index ]
    resources :class_schedules, only: [ :index ]
    resources :documents, only: [ :index, :show ]
    resources :events, only: [ :index, :show ]
    resources :occurrences, only: [ :index, :show ]
    root to: "dashboard#index"
  end

  # Rotas de teste (apenas para desenvolvimento)
  get "/test/users", to: "test#users"
  post "/test/login_as/:id", to: "test#login_as", as: "test_login_as"
end
