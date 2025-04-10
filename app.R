# Required Libraries (Sem rmarkdown/tinytex aqui, pois o PDF é pré-gerado)
# install.packages(c("shiny", "shinyjs", "DT", "shinyWidgets", "shinyFeedback", "bslib", "RSQLite", "DBI")) # Run once if needed
library(shiny)
library(shinyjs)
library(DT)
library(shinyWidgets)
library(shinyFeedback)
library(bslib) # Para temas Bootstrap modernos
library(RSQLite)
library(DBI)

# --- Database Setup ---
# Create database connection with optimized settings
db_path <- "app_data.db"
db_conn <- dbConnect(SQLite(), db_path)

# Enable foreign keys and optimize settings
dbExecute(db_conn, "PRAGMA foreign_keys = ON")
dbExecute(db_conn, "PRAGMA journal_mode = WAL")  # Write-Ahead Logging for better performance
dbExecute(db_conn, "PRAGMA synchronous = NORMAL")  # Good balance between safety and performance

# Create tables if they don't exist with proper indexing
dbExecute(db_conn, "
  CREATE TABLE IF NOT EXISTS contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    message TEXT,
    source TEXT,
    UNIQUE(email, timestamp)
  )
")

dbExecute(db_conn, "
  CREATE TABLE IF NOT EXISTS leads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    email TEXT NOT NULL,
    source TEXT,
    UNIQUE(email, timestamp)
  )
")

# Create indexes for better performance
dbExecute(db_conn, "CREATE INDEX IF NOT EXISTS idx_contacts_email ON contacts(email)")
dbExecute(db_conn, "CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email)")

# --- Helper Function (Data Saving) ---
saveData <- function(data, type = "contact") {
  tryCatch({
    # Sanitize inputs to prevent SQL injection
    sanitize_input <- function(x) {
      if (is.null(x) || is.na(x)) return("")
      return(as.character(x))
    }
    
    if (type == "contact") {
      # Check if this email already exists in the last 24 hours to prevent duplicates
      recent_contact <- dbGetQuery(db_conn, "
        SELECT COUNT(*) as count FROM contacts 
        WHERE email = ? AND timestamp > datetime('now', '-1 day')
      ", list(sanitize_input(data$Email)))
      
      if (recent_contact$count > 0) {
        return(FALSE)  # Duplicate submission
      }
      
      # Insert the new contact
      dbExecute(db_conn, "
        INSERT INTO contacts (name, email, message, source)
        VALUES (?, ?, ?, ?)
      ", list(
        sanitize_input(data$Name),
        sanitize_input(data$Email),
        sanitize_input(data$Message),
        sanitize_input(data$Source)
      ))
    } else if (type %in% c("lead_popup", "lead_download")) {
      # Check if this email already exists in the last 24 hours to prevent duplicates
      recent_lead <- dbGetQuery(db_conn, "
        SELECT COUNT(*) as count FROM leads 
        WHERE email = ? AND timestamp > datetime('now', '-1 day')
      ", list(sanitize_input(data$Email)))
      
      if (recent_lead$count > 0) {
        return(FALSE)  # Duplicate submission
      }
      
      # Insert the new lead
      dbExecute(db_conn, "
        INSERT INTO leads (email, source)
        VALUES (?, ?)
     ", list(
       sanitize_input(data$Email),
       sanitize_input(data$Source)
     ))
    }
    
    # Compact the database periodically to save space
    if (runif(1) < 0.1) {  # 10% chance to compact on each save
      dbExecute(db_conn, "VACUUM")
    }
    
    return(TRUE)
  }, error = function(e) {
    warning(paste("Database error:", e$message))
    return(FALSE)
  })
}

# --- Helper Function (Data Export) ---
exportData <- function(type = "all") {
  tryCatch({
    if (type == "contacts" || type == "all") {
      contacts <- dbGetQuery(db_conn, "SELECT * FROM contacts ORDER BY timestamp DESC")
    } else {
      contacts <- data.frame()
    }
    
    if (type == "leads" || type == "all") {
      leads <- dbGetQuery(db_conn, "SELECT * FROM leads ORDER BY timestamp DESC")
    } else {
      leads <- data.frame()
    }
    
    return(list(contacts = contacts, leads = leads))
  }, error = function(e) {
    warning(paste("Export error:", e$message))
    return(list(contacts = data.frame(), leads = data.frame()))
  })
}

# --- Helper Function (Nullable Check) ---
`%||%` <- function(a, b) { if (!is.null(a) && !is.na(a) && length(a) > 0 && nzchar(a)) a else b }

# --- UI Definition ---
ui <- fluidPage(
  theme = bslib::bs_theme(version = 4, bootswatch = "darkly"),
  useShinyjs(),
  useShinyFeedback(),
  tags$head(
    tags$title("Aulas de Inglês | GREATEST SHOW ENGLISH"),
    tags$meta(name = "description", content = "Aulas de inglês online personalizadas com professor experiente. Método focado em conversação e resultados rápidos."),
    tags$meta(name = "keywords", content = "aula de inglês, professor de inglês, inglês online, curso de inglês, aprender inglês, conversação em inglês"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1.0"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;700&family=Montserrat:wght@700&display=swap"),
    tags$style(HTML("
      body { font-family: 'Roboto', sans-serif; line-height: 1.6; padding-top: 70px; }
      h1, h2, h3, h4, h5, h6 { font-family: 'Montserrat', sans-serif; font-weight: 700; }
      .section { padding: 60px 15px; text-align: center; border-bottom: 1px solid #444; }
      .section:last-child { border-bottom: none; }
      #hero { min-height: 60vh; display: flex; flex-direction: column; justify-content: center; align-items: center; background-color: #222; }
      #hero h1 { font-size: 2.5rem; margin-bottom: 15px; color: #FFF; }
      #hero p { font-size: 1.1rem; margin-bottom: 30px; color: #CCC; }
      #sobre, #depoimentos, #demo, #download { background-color: #303030; }
      #metodo, #contato { background-color: #3a3a3a; }
      .navbar-custom { background-color: rgba(30, 30, 30, 0.9); padding: 10px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.4); position: sticky; top: 0; z-index: 1020; border-bottom: 1px solid #444; }
      .navbar-custom .container { display: flex; justify-content: space-around; align-items: center; flex-wrap: wrap; max-width: 1140px; margin: 0 auto; }
      .navbar-custom a { color: #adb5bd; text-decoration: none; padding: 5px 10px; font-weight: bold; transition: color 0.3s ease; }
      .navbar-custom a:hover { color: #FFF; text-decoration: none; }
      .icon-feature { font-size: 3em; color: #00bc8c; margin-bottom: 15px; }
      .btn-success { background-color: #00bc8c; border-color: #00a178; }
      .btn-primary { background-color: #3498db; border-color: #2c81ba; }
      .btn-info { background-color: #4ecca3; border-color: #41aa8a; color: #222; }
      .btn-lg { padding: 1rem 1.5rem; font-size: 1.25rem; }
      .floating-whatsapp .btn { background-color: #25D366; }
      .floating-whatsapp .btn:hover { background-color: #128C7E; }
      .form-control { background-color: #444; color: #eee; border: 1px solid #555; }
      .form-control::placeholder { color: #aaa; }
      .form-control:focus { background-color: #555; color: #fff; border-color: #00bc8c; box-shadow: none; }
      label { color: #ccc; }
       .dataTables_wrapper .dataTables_length, .dataTables_wrapper .dataTables_filter, .dataTables_wrapper .dataTables_info, .dataTables_wrapper .dataTables_processing, .dataTables_wrapper .dataTables_paginate { color: #ccc !important; }
       table.dataTable { border-color: #555 !important; }
       table.dataTable th, table.dataTable td { color: #ccc !important; border-color: #555 !important; }
       table.dataTable thead th { background-color: #3a3a3a !important; }
       table.dataTable tbody tr:nth-child(odd) { background-color: #303030 !important; }
       table.dataTable tbody tr:nth-child(even) { background-color: #353535 !important; }
       table.dataTable tbody tr:hover { background-color: #454545 !important; }
       #demo_plot_base { background: transparent !important; }
       #admin-panel { display: none; }
       .admin-toggle { position: fixed; bottom: 20px; right: 20px; z-index: 9999; opacity: 0.3; }
       .admin-toggle:hover { opacity: 1; }
    "))
  ),
  
  # --- Simple Sticky Navigation ---
  tags$nav(class = "navbar-custom",
           tags$div(class = "container",
                    tags$a(href="#hero", "Início"),
                    tags$a(href="#sobre", "Sobre"),
                    tags$a(href="#metodo", "Método"),
                    tags$a(href="#depoimentos", "Depoimentos"),
                    tags$a(href="#demo", "Resultados"),
                    tags$a(href="#contato", "Contato"),
                    tags$a(href="#download", "Material Grátis")
           )
  ),
  
  # --- Section 1: Hero ---
  tags$div(id = "hero", class = "section",
           tags$div(class="container",
                    h1("Aprenda Inglês com um Professor Certificado"),
                    p("5 anos de experiência | Aulas personalizadas | Resultados comprovados"),
                    actionButton("cta_hero_btn", "Quero minha Aula Experimental Grátis!", class = "btn btn-lg btn-success")
           )
  ),
  
  # --- Section 2: Sobre ---
  tags$div(id = "sobre", class = "section",
           tags$div(class = "container",
                    h2("Por que escolher o GREATEST SHOW ENGLISH?"), br(),
                    fluidRow( class="justify-content-center",
                              column(width = 4, div(class = "icon-feature", icon("chalkboard-teacher")), h4("Ensino Personalizado"), p("Aulas adaptadas...")),
                              column(width = 4, div(class = "icon-feature", icon("comments")), h4("Foco em Conversação"), p("Desenvolva fluência...")),
                              column(width = 4, div(class = "icon-feature", icon("chart-line")), h4("Acompanhamento Contínuo"), p("Feedback constante..."))
                    )
           )
  ),
  
  # --- Section 3: Metodo ---
  tags$div(id = "metodo", class = "section",
           tags$div(class = "container",
                    h2("Metodologia Validada"),
                    p("Meu método combina técnicas modernas..."),
                    tags$ul(style = "list-style: none; padding: 0; max-width: 600px; margin: auto; text-align: left;",
                            tags$li(icon("check-circle", style="color: #00bc8c; margin-right: 8px;"), " Material didático interativo"),
                            tags$li(icon("check-circle", style="color: #00bc8c; margin-right: 8px;"), " Aulas dinâmicas e participativas"),
                            tags$li(icon("check-circle", style="color: #00bc8c; margin-right: 8px;"), " Ênfase em situações reais")
                    )
           )
  ),
  
  # --- Section 4: Depoimentos ---
  tags$div(id = "depoimentos", class = "section",
           tags$div(class = "container",
                    h2("O que meus alunos dizem"),
                    p("Veja como o GREATEST SHOW ENGLISH ajudou..."),
                    DTOutput("testimonials")
           )
  ),
  
  # --- Section 5: Demo (Base R Plot) ---
  tags$div(id = "demo", class = "section",
           tags$div(class = "container",
                    h2("Resultados Comprovados"),
                    p("Veja a eficácia do método..."),
                    plotOutput("demo_plot_base", height = "400px")
           )
  ),
  
  # --- Section 6: Contato ---
  tags$div(id = "contato", class = "section",
           tags$div(class = "container",
                    h2("Agende sua Aula Experimental Gratuita!"),
                    p("Preencha o formulário para marcar..."),
                    fluidRow( class = "justify-content-center",
                              column(width = 8, class="col-md-8",
                                     textInput("name", "Seu Nome Completo:", placeholder = "Ex: João da Silva"),
                                     textInput("email", "Seu Melhor Email:", placeholder = "Ex: joao.silva@email.com"),
                                     textAreaInput("message", "Sua Mensagem (Opcional):", rows = 3, placeholder = "..."),
                                     actionButton("submit_contact", "Quero Agendar Minha Aula!", class = "btn btn-primary btn-lg")
                              )
                    )
           )
  ),
  
  # --- Section 7: Download ---
  tags$div(id = "download", class = "section",
           tags$div(class = "container",
                    h2("Baixe seu Guia Gratuito!"),
                    p("Deixe seu email e receba um guia exclusivo..."),
                    fluidRow( class = "justify-content-center",
                              column(width = 6, class="col-md-6",
                                     textInput("email_download", "Seu Email:", placeholder = "Digite seu email..."),
                                     # Este botão agora usa o downloadHandler que COPIA o arquivo pré-gerado
                                     downloadButton("download_guide", "Baixar Guia Agora!", class="btn btn-info")
                              )
                    )
           )
  ),
  
  # --- Floating WhatsApp Button ---
  tags$div(class="floating-whatsapp",
           actionButton("whatsapp_button", icon("whatsapp"), onclick = "window.open('https://wa.me/55XXXXXXXXXXX?text=...%20aulas%20de%20inglês.', '_blank')")
           # !! Lembre-se de substituir 55XXXXXXXXXXX !!
  ),
  
  # --- Admin Panel Toggle Button ---
  tags$div(class="admin-toggle",
           actionButton("admin_toggle", icon("cog"), class="btn btn-sm btn-secondary")
  ),
  
  # --- Admin Panel ---
  tags$div(id = "admin-panel", class = "section",
           tags$div(class = "container",
                    h2("Painel Administrativo"),
                    p("Visualize e exporte os dados coletados."),
                    fluidRow(
                      column(width = 6,
                             h3("Contatos"),
                             DTOutput("admin_contacts"),
                             downloadButton("download_contacts", "Exportar Contatos", class="btn btn-sm btn-info")
                      ),
                      column(width = 6,
                             h3("Leads"),
                             DTOutput("admin_leads"),
                             downloadButton("download_leads", "Exportar Leads", class="btn btn-sm btn-info")
                      )
                    ),
                    fluidRow(
                      column(width = 12,
                             actionButton("close_admin", "Fechar Painel", class="btn btn-sm btn-secondary")
                      )
                    )
           )
  )
  
) # End fluidPage


# --- Server Logic ---
server <- function(input, output, session) {
  
  # --- Reactive Values ---
  rv <- reactiveValues(
    has_registered_this_session = FALSE,
    admin_panel_visible = FALSE
  )
  
  # --- Admin Panel Toggle ---
  observeEvent(input$admin_toggle, {
    rv$admin_panel_visible <- !rv$admin_panel_visible
    if (rv$admin_panel_visible) {
      shinyjs::show("admin-panel")
      shinyjs::runjs("window.scrollTo(0, 0);")
    } else {
      shinyjs::hide("admin-panel")
    }
  })
  
  # --- Close Admin Panel ---
  observeEvent(input$close_admin, {
    rv$admin_panel_visible <- FALSE
    shinyjs::hide("admin-panel")
  })
  
  # --- Admin Panel Data Tables ---
  output$admin_contacts <- renderDT({
    data <- exportData("contacts")$contacts
    if (nrow(data) == 0) {
      data <- data.frame(Message = "Nenhum contato registrado ainda.")
    }
    datatable(data,
              rownames = FALSE, escape = FALSE, class = 'cell-border stripe compact hover',
              options = list(pageLength = 5, searching = TRUE, info = TRUE, autoWidth = TRUE, scrollX = TRUE)
    )
  })
  
  output$admin_leads <- renderDT({
    data <- exportData("leads")$leads
    if (nrow(data) == 0) {
      data <- data.frame(Message = "Nenhum lead registrado ainda.")
    }
    datatable(data,
              rownames = FALSE, escape = FALSE, class = 'cell-border stripe compact hover',
              options = list(pageLength = 5, searching = TRUE, info = TRUE, autoWidth = TRUE, scrollX = TRUE)
    )
  })
  
  # --- Export Data ---
  output$download_contacts <- downloadHandler(
    filename = function() {
      paste("contacts_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv", sep = "")
    },
    content = function(file) {
      data <- exportData("contacts")$contacts
      write.csv(data, file, row.names = FALSE)
    }
  )
  
  output$download_leads <- downloadHandler(
    filename = function() {
      paste("leads_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv", sep = "")
    },
    content = function(file) {
      data <- exportData("leads")$leads
      write.csv(data, file, row.names = FALSE)
    }
  )
  
  # --- Observe Hero Button Click ---
  observeEvent(input$cta_hero_btn, {
    shinyjs::runjs("document.getElementById('contato').scrollIntoView({ behavior: 'smooth' });")
  })
  
  # --- Exit Intent Pop-up Logic ---
  delay_ms <- 3000
  jsCode <- paste0("
    var exitIntentFired = false; var exitTimeout;
    $(document).on('mouseleave', 'body', function(e) {
      if (e.clientY <= 0 && !exitIntentFired && !$('body').hasClass('modal-open')) {
        clearTimeout(exitTimeout);
        exitTimeout = setTimeout(function() {
           if (!exitIntentFired && !$('body').hasClass('modal-open')) {
             Shiny.setInputValue('exit_intent', Date.now(), {priority: 'event'});
             exitIntentFired = true;
           }
        }, ", delay_ms, ");
      }
    });
    $(document).on('mouseenter', 'body', function(e) { clearTimeout(exitTimeout); });
    $(document).on('click', function(e) { clearTimeout(exitTimeout); });
  ")
  shinyjs::runjs(jsCode)
  
  observeEvent(input$exit_intent, {
    req(input$exit_intent)
    if (!rv$has_registered_this_session) {
      showModal(modalDialog(
        useShinyFeedback(),
        title = tags$h3("👋 Não vá ainda!", style="text-align:center; color: #00bc8c;"),
        p("Que tal receber dicas exclusivas?", style="text-align:center; font-size: 1.1em;"),
        textInput("lead_email_popup", "Seu Melhor Email:", placeholder = "seu.email@exemplo.com"),
        footer = tagList( modalButton("Fechar"), actionButton("send_lead_popup", "Quero Receber Dicas!", class = "btn btn-success") ),
        easyClose = TRUE, fade = TRUE
      ))
    }
  }, ignoreNULL = TRUE)
  
  # --- Handle Exit Intent Lead Submission ---
  observeEvent(input$send_lead_popup, {
    req(input$lead_email_popup)
    local_email <- trimws(input$lead_email_popup)
    if (grepl(".+@.+\\..+", local_email)) {
      shinyFeedback::hideFeedback("lead_email_popup")
      showNotification("Obrigado! Verifique seu email.", type = "message")
      saveData(data.frame(Timestamp = Sys.time(), Email = local_email, Source = "Exit Popup"), type = "lead_popup")
      rv$has_registered_this_session <- TRUE
      removeModal()
    } else {
      shinyFeedback::showFeedback("lead_email_popup", "Por favor, insira um email válido.", type = "warning")
    }
  })
  
  # --- Render Testimonials Table ---
  output$testimonials <- renderDT({
    comments_data <- data.frame(
      Aluno = c("Maria S.", "João P.", "Ana C.", "Carlos M."),
      Depoimento = c("\"Finalmente perdi o medo...\"", "\"Consegui a promoção...\"", "\"Adoro a dinâmica...\"", "\"Método focado...\""),
      Nota = rep("⭐⭐⭐⭐⭐", 4)
    )
    datatable(comments_data,
              rownames = FALSE, escape = FALSE, class = 'cell-border stripe compact hover',
              options = list( paging = FALSE, searching = FALSE, info = FALSE, autoWidth = TRUE, scrollX = TRUE,
                              columnDefs = list(list(className = 'dt-center', targets = "_all")), dom = 't')
    )
  }, server = FALSE)
  
  # --- Render Demo Plot (Base R) ---
  output$demo_plot_base <- renderPlot({
    niveis <- c("Básico", "Intermediário", "Avançado")
    valores <- c(85, 92, 78)
    cores <- c("#ff4e50", "#fc913a", "#f9d423")
    par(bg = NA, fg = "#cccccc", col.axis = "#cccccc", col.lab="#cccccc", col.main="#ffffff", font.lab=2, cex.axis=0.9, cex.lab=1.1, cex.main=1.3, mar=c(4, 5, 3, 2))
    bp <- barplot(valores, names.arg = niveis, col = cores, border = "#444444", main = "Eficácia do Método por Nível", ylab = "% de Alunos Aprovados/Satisfeitos", ylim = c(0, 100) )
    text(bp, valores + 3, labels = paste0(valores, "%"), col = "#ffffff", cex=0.9)
  }, bg = "transparent")
  
  # --- Handle Contact Form Submission ---
  observeEvent(input$submit_contact, {
    valid_form <- TRUE
    name_val <- trimws(input$name)
    email_val <- trimws(input$email)
    
    # Clear any existing feedback
    shinyFeedback::hideFeedback("name")
    shinyFeedback::hideFeedback("email")
    
    if (nchar(name_val) < 2) { 
      shinyFeedback::showFeedback("name", "Nome inválido.", type = "warning")
      valid_form <- FALSE 
    } else { 
      shinyFeedback::showFeedback("name", "", type = "success") 
    }
    
    if (!grepl(".+@.+\\..+", email_val)) { 
      shinyFeedback::showFeedback("email", "Email inválido.", type = "warning")
      valid_form <- FALSE 
    } else { 
      shinyFeedback::showFeedback("email", "", type = "success") 
    }
    
    if (valid_form) {
      contact_data <- data.frame( Timestamp = Sys.time(), Name = name_val, Email = email_val, Message = input$message, Source = "Contact Form")
      saveData(contact_data, type = "contact")
      showNotification("Obrigado! Retornaremos em breve.", type = "message", duration = 5)
      updateTextInput(session, "name", value = "")
      updateTextInput(session, "email", value = "")
      updateTextAreaInput(session, "message", value = "")
      shinyFeedback::hideFeedback("name")
      shinyFeedback::hideFeedback("email")
    } else {
      showNotification("Por favor, corrija os campos indicados.", type = "warning", duration = 5)
    }
  })
  
  # --- Handle Downloadable Guide (Copia arquivo PRÉ-GERADO) ---
  output$download_guide <- downloadHandler(
    filename = function() {
      "Guia_Rapido_Ingles_GREATEST_SHOW.pdf" # Nome que o usuário verá
    },
    content = function(file) {
      # 'file' é o caminho temporário onde o Shiny salva o arquivo para o usuário baixar
      
      # 1. Validar Email
      local_email_dl <- trimws(input$email_download)
      if (!grepl(".+@.+\\..+", local_email_dl)) {
        shinyFeedback::showFeedback("email_download", "Email inválido.", type = "warning")
        showNotification("Email inválido.", type = "warning", duration=5)
        # Importante: precisamos escrever ALGO em 'file' para não dar erro fatal
        # Escrevemos uma mensagem de erro no PDF que será baixado.
        pdf(file)
        plot.new()
        text(0.5, 0.5, "Erro: Email inválido fornecido.", col = "red")
        dev.off()
        return() # Interrompe
      }
      
      # 2. Salvar Lead
      shinyFeedback::showFeedback("email_download", "Obrigado! Download iniciado...", type = "success")
      lead_data <- data.frame( Timestamp = Sys.time(), Email = local_email_dl, Source = "Download Guide")
      saveData(lead_data, type = "lead_download")
      rv$has_registered_this_session <- TRUE
      
      # 3. COPIAR o arquivo PDF pré-gerado
      source_file <- "guia_ingles.pdf" # O nome do SEU arquivo PDF
      
      if (file.exists(source_file)) {
        if (!file.copy(source_file, file, overwrite = TRUE)) {
          warning(paste("Falha ao copiar:", source_file, "para", file))
          showNotification("Erro ao preparar o arquivo para download.", type="error", duration=10)
          # Tenta escrever uma mensagem de erro no PDF
          pdf(file)
          plot.new()
          text(0.5, 0.5, "Erro interno ao copiar o arquivo guia.", col = "red")
          dev.off()
        }
        # Se file.copy funcionou, o arquivo está pronto em 'file'
      } else {
        warning(paste("Arquivo fonte não encontrado:", source_file))
        showNotification("Erro interno: Arquivo Guia não encontrado no servidor.", type="error", duration=10)
        # Tenta escrever uma mensagem de erro no PDF
        pdf(file)
        plot.new()
        text(0.5, 0.5, "Erro interno: Arquivo Guia não disponível.", col = "red")
        dev.off()
      }
      
      # Limpa o input após a tentativa (mesmo se falhou em copiar)
      shinyjs::delay(1000, {
        updateTextInput(session, "email_download", value = "")
        shinyFeedback::hideFeedback("email_download")
      })
      
    },
    contentType = "application/pdf" # Define o tipo de conteúdo
  ) # Fim downloadHandler
  
  # --- Cleanup on Session End ---
  session$onSessionEnded(function() {
    # Close database connection
    if (exists("db_conn") && dbIsValid(db_conn)) {
      dbDisconnect(db_conn)
    }
    
    # Compact the database to save space
    tryCatch({
      temp_conn <- dbConnect(SQLite(), db_path)
      dbExecute(temp_conn, "VACUUM")
      dbDisconnect(temp_conn)
    }, error = function(e) {
      warning(paste("Error compacting database:", e$message))
    })
  })
  
} # End server

# --- Run the Application ---
shinyApp(ui = ui, server = server)