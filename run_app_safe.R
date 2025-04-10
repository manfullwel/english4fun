# Script para executar o aplicativo Shiny com verificações adicionais
cat("Iniciando o aplicativo Shiny com verificações adicionais...\n\n")

# Verificar se o pacote shinyFeedback está instalado e carregado corretamente
if (!requireNamespace("shinyFeedback", quietly = TRUE)) {
  cat("O pacote shinyFeedback não está instalado. Instalando...\n")
  install.packages("shinyFeedback")
}

# Carregar o pacote shinyFeedback explicitamente
library(shinyFeedback)

# Verificar se as funções do shinyFeedback estão disponíveis
if (!exists("showFeedback") || !exists("hideFeedback")) {
  cat("ERRO: As funções do pacote shinyFeedback não estão disponíveis.\n")
  cat("Tente reinstalar o pacote shinyFeedback:\n\n")
  cat("install.packages(\"shinyFeedback\")\n")
  quit(save = "no")
}

# Carregar outros pacotes necessários
required_packages <- c("shiny", "shinyjs", "DT", "shinyWidgets", "bslib", "RSQLite", "DBI", "promises")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("O pacote", pkg, "não está instalado. Instalando...\n")
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# Verificar se o arquivo app.R existe
if (!file.exists("app.R")) {
  stop("O arquivo app.R não foi encontrado no diretório atual.")
}

# Executar o aplicativo
cat("\nAcesse http://localhost:3838 no seu navegador\n")
cat("Pressione Ctrl+C para encerrar o aplicativo\n\n")

# Executar o aplicativo na porta 3838
runApp("app.R", host = "0.0.0.0", port = 3838) 