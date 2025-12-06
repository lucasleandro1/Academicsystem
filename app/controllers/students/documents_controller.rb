class Students::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student
  before_action :set_document, only: [ :show, :download, :destroy ]

  require "prawn" if defined?(Prawn)

  def index
    # Buscar documentos que o estudante pode visualizar
    @documents = Document.joins(:school)
                        .where(school: current_user.school)
                        .select { |doc| doc.can_be_viewed_by?(current_user) }
                        .sort_by(&:created_at)
                        .reverse

    # Separar em documentos próprios e recebidos
    @my_documents = @documents.select { |doc| doc.user_id == current_user.id }
    @received_documents = @documents.select { |doc| doc.user_id != current_user.id }

    # Agrupamento por tipo de documento
    @documents_by_type = @documents.group_by(&:document_type)
                                  .transform_values(&:count)
  end

  def show
    unless @document.can_be_viewed_by?(current_user)
      redirect_to students_documents_path, alert: "Você não tem permissão para acessar este documento."
    end
  end

  def new
    @document = Document.new
    @document.user = current_user
  end

  def create
    @document = Document.new(document_params)
    @document.user = current_user
    @document.school = current_user.school
    @document.sharing_type = "specific_user"
    @document.recipient = current_user
    @document.attached_by = current_user

    if @document.save
      redirect_to students_documents_path, notice: "Documento adicionado com sucesso."
    else
      render :new
    end
  end

  def destroy
    # Aluno só pode excluir seus próprios documentos
    if @document.user_id == current_user.id
      @document.destroy
      redirect_to students_documents_path, notice: "Documento removido com sucesso."
    else
      redirect_to students_documents_path, alert: "Você não tem permissão para remover este documento."
    end
  end

  def download
    unless @document.can_be_viewed_by?(current_user)
      redirect_to students_documents_path, alert: "Você não tem permissão para baixar este documento."
      return
    end

    if @document.attachment.attached?
      response.headers["Cache-Control"] = "no-cache, no-store"
      response.headers["Content-Security-Policy"] = "default-src 'self'"

      send_data @document.attachment.download,
                filename: @document.attachment.filename.to_s,
                type: @document.attachment.content_type || "application/octet-stream",
                disposition: "attachment"
    elsif @document.file_path.present? && File.exist?(@document.file_path)
      response.headers["Cache-Control"] = "no-cache, no-store"
      response.headers["Content-Security-Policy"] = "default-src 'self'"

      send_file @document.file_path,
                filename: File.basename(@document.file_path),
                disposition: "attachment"
    else
      redirect_to students_documents_path, alert: "Arquivo não encontrado."
    end
  end

  def generate_report_card
    unless current_user.classroom
      redirect_to students_documents_path, alert: "Você precisa estar matriculado em uma turma para gerar o boletim."
      return
    end

    # Buscar notas do estudante agrupadas por disciplina e bimestre
    @student = current_user
    @classroom = current_user.classroom
    @school = current_user.school

    # Buscar disciplinas através dos horários da turma
    subjects = @classroom.class_schedules.includes(:subject).map(&:subject).uniq

    if subjects.empty?
      redirect_to students_documents_path, alert: "Sua turma não possui disciplinas cadastradas. Entre em contato com a direção."
      return
    end

    @grades_data = {}
    
    # Determinar quais bimestres exibir baseado no bimestre selecionado
    selected_bimester = params[:bimester].to_i
    @period_label = if selected_bimester > 0
                      "#{selected_bimester}º Bimestre"
                    else
                      "Ano Completo"
                    end
    
    @bimesters = if selected_bimester > 0
                   [ selected_bimester ]
                 else
                   [ 1, 2, 3, 4 ] # Boletim completo
                 end
    
    @subject_averages = {}
    @bimester_averages = {}

    # Verificar se há pelo menos uma nota cadastrada
    total_grades = @student.student_grades.where(subject: subjects, bimester: @bimesters)
    if total_grades.empty?
      redirect_to students_documents_path, alert: "Você ainda não possui notas lançadas para o período selecionado. O boletim será gerado assim que as notas estiverem disponíveis."
      return
    end

    subjects.each do |subject|
      @grades_data[subject] = {}
      subject_total = 0
      subject_count = 0

      @bimesters.each do |bimester|
        grades = @student.student_grades
                         .where(subject: subject, bimester: bimester)

        if grades.any?
          # Calcular média das notas do bimestre para a disciplina
          bimester_average = grades.average(:value).round(1)
          @grades_data[subject][bimester] = bimester_average
          subject_total += bimester_average
          subject_count += 1
        else
          @grades_data[subject][bimester] = nil
        end
      end

      # Calcular média do período da disciplina
      @subject_averages[subject] = subject_count > 0 ? (subject_total / subject_count).round(1) : nil
    end

    # Calcular médias por bimestre (todas as disciplinas)
    @bimesters.each do |bimester|
      bimester_grades = []
      @grades_data.each do |subject, bimesters|
        if bimesters[bimester].present?
          bimester_grades << bimesters[bimester]
        end
      end
      @bimester_averages[bimester] = bimester_grades.any? ? (bimester_grades.sum / bimester_grades.size).round(1) : nil
    end

    # Calcular média geral do período
    all_subject_averages = @subject_averages.values.compact
    @overall_average = all_subject_averages.any? ? (all_subject_averages.sum / all_subject_averages.size).round(1) : nil

    # Gerar PDF do boletim
    respond_to do |format|
      format.pdf do
        pdf = generate_report_card_pdf
        period_suffix = selected_bimester > 0 ? "_#{@period_label.parameterize}" : ""
        send_data pdf, filename: "boletim_#{@student.full_name.parameterize}#{period_suffix}_#{Date.current.strftime('%Y%m%d')}.pdf",
                       type: "application/pdf",
                       disposition: "attachment"
      end
      format.html { redirect_to generate_report_card_students_documents_path(format: :pdf) }
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def ensure_student
    redirect_to root_path unless current_user.student?
  end

  def document_params
    params.require(:document).permit(:title, :description, :document_type, :attachment)
  end

  def generate_report_card_pdf
    begin
      require "prawn"
      require "prawn/table"
      # Suprimir warning UTF-8
      Prawn::Fonts::AFM.hide_m17n_warning = true
    rescue LoadError
      raise LoadError, "Prawn gem is required for PDF generation. Please run 'bundle install' and restart the server."
    end

    Prawn::Document.new(page_size: "A4", margin: [ 50, 50, 50, 50 ]) do |pdf|
      # Configurar fonte
      pdf.font "Helvetica"

      # Cabeçalho com logo (se houver) e título
      pdf.text_box "BOLETIM ESCOLAR", at: [ 0, pdf.cursor ], width: 540, align: :center,
                   style: :bold, size: 20, color: "2c3e50"
      
      # Subtítulo com período selecionado
      pdf.move_down 30
      pdf.text_box @period_label, at: [ 0, pdf.cursor ], width: 540, align: :center,
                   style: :bold, size: 14, color: "3498db"

      pdf.move_down 30

      # Informações da escola em caixa destacada
      pdf.stroke_color "d5d5d5"
      pdf.stroke_rectangle [ 0, pdf.cursor ], 540, 60
      pdf.fill_color "f8f9fa"
      pdf.fill_rectangle [ 0, pdf.cursor ], 540, 60
      pdf.fill_color "000000"

      pdf.move_down 15
      pdf.indent(10) do
        pdf.text "#{@school.name}", style: :bold, size: 14
        if @school.address.present?
          pdf.text "#{@school.address}", size: 10
        end
        pdf.text "Ano Letivo: #{Date.current.year}", style: :bold, size: 10
      end

      pdf.move_down 30

      # Informações do aluno
      pdf.text "DADOS DO ALUNO", style: :bold, size: 14, color: "2c3e50"
      pdf.move_down 5
      pdf.stroke_color "3498db"
      pdf.line_width 2
      pdf.stroke_horizontal_line 0, 100, at: pdf.cursor
      pdf.move_down 15

      info_data = [
        [ "Nome:", @student.full_name ],
        [ "Turma:", @classroom.name ],
        [ "Período:", @period_label ],
        [ "Data de emissão:", Date.current.strftime("%d/%m/%Y") ]
      ]

      pdf.table info_data, width: 540, cell_style: { borders: [], padding: [ 2, 0 ] } do
        columns(0).font_style = :bold
        columns(0).width = 120
      end

      pdf.move_down 30

      # Título da seção de notas
      pdf.text "DESEMPENHO ACADÊMICO", style: :bold, size: 14, color: "2c3e50"
      pdf.move_down 5
      pdf.stroke_color "3498db"
      pdf.line_width 2
      pdf.stroke_horizontal_line 0, 150, at: pdf.cursor
      pdf.move_down 15

      # Preparar dados da tabela com headers dinâmicos
      table_data = []
      headers = [ "Disciplina" ]
      
      # Adicionar headers dos bimestres selecionados
      @bimesters.each do |bimester|
        headers << "#{bimester}º Bim"
      end
      
      headers << "Média"
      headers << "Situação"
      table_data << headers

      @grades_data.each do |subject, bimesters|
        row = []
        row << subject.name

        @bimesters.each do |bimester|
          grade = bimesters[bimester]
          row << (grade.present? ? sprintf("%.1f", grade) : "-")
        end

        avg = @subject_averages[subject]
        row << (avg.present? ? sprintf("%.1f", avg) : "-")

        # Situação (aprovado/reprovado)
        if avg.present?
          row << (avg >= 6.0 ? "Aprovado" : "Reprovado")
        else
          row << "Em análise"
        end

        table_data << row
      end

      # Adicionar linha de médias por bimestre
      if @bimester_averages.any? { |_, avg| avg.present? }
        avg_row = [ "MÉDIA GERAL" ]
        @bimesters.each do |bimester|
          avg = @bimester_averages[bimester]
          avg_row << (avg.present? ? sprintf("%.1f", avg) : "-")
        end
        avg_row << (@overall_average.present? ? sprintf("%.1f", @overall_average) : "-")

        if @overall_average.present?
          if @overall_average >= 6.0
            avg_row << "APROVADO"
          else
            avg_row << "EM RECUPERAÇÃO"
          end
        else
          avg_row << "EM ANÁLISE"
        end

        table_data << avg_row
      end

      # Renderizar tabela
      bimester_columns_count = @bimesters.size
      pdf.table table_data, header: true, width: 540 do
        row(0).font_style = :bold
        row(0).background_color = "3498db"
        row(0).text_color = "ffffff"

        if table_data.length > 1
          row(-1).font_style = :bold
          row(-1).background_color = "ecf0f1"
        end

        # Centralizar colunas dos bimestres, média e situação dinamicamente
        columns(1..(bimester_columns_count + 1)).align = :center

        self.cell_style = {
          size: 10,
          padding: [ 8, 5 ],
          border_color: "bdc3c7"
        }

        # Colorir situações
        if table_data.length > 1
          (1...table_data.length).each do |i|
            situation_col_index = bimester_columns_count + 2
            if table_data[i][situation_col_index] == "Aprovado"
              self.row(i).columns(situation_col_index).background_color = "d5f4e6"
              self.row(i).columns(situation_col_index).text_color = "27ae60"
            elsif table_data[i][situation_col_index] == "Reprovado"
              self.row(i).columns(situation_col_index).background_color = "fadbd8"
              self.row(i).columns(situation_col_index).text_color = "e74c3c"
            end
          end
        end
      end

      pdf.move_down 30

      # Informações adicionais em caixa
      pdf.stroke_color "f39c12"
      pdf.stroke_rectangle [ 0, pdf.cursor ], 540, 50
      pdf.fill_color "fef9e7"
      pdf.fill_rectangle [ 0, pdf.cursor ], 540, 50
      pdf.fill_color "000000"

      pdf.move_down 10
      pdf.indent(10) do
        pdf.text "INFORMAÇÕES IMPORTANTES:", style: :bold, size: 10, color: "f39c12"
        pdf.text "• Média mínima para aprovação: 6,0", size: 9
        pdf.text "• (-) = Nota ainda não lançada pelo professor", size: 9
      end

      pdf.move_down 30

      # Data e assinatura
      pdf.text_box "______________________________", at: [ 350, pdf.cursor ], width: 190, align: :center
      pdf.move_down 15
      pdf.text_box "Direção Escolar", at: [ 350, pdf.cursor ], width: 190, align: :center, size: 10, style: :bold

      pdf.move_down 40

      # Footer
      pdf.text "Este documento foi gerado automaticamente em #{Time.current.strftime('%d/%m/%Y às %H:%M')}",
               size: 8, style: :italic, align: :center, color: "7f8c8d"
    end.render
  end
end
