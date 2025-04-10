# Script para executar o aplicativo Shiny sem problemas com o pacote promises
cat("Iniciando o aplicativo Shiny...\n")

# Verificar se o pacote promises está instalado e na versão correta
if (!requireNamespace("promises", quietly = TRUE) || packageVersion("promises") < "1.3.2") {
  cat("O pacote promises precisa ser atualizado.\n")
  cat("Por favor, feche o RStudio completamente e abra novamente.\n")
  cat("Depois execute os seguintes comandos:\n\n")
  cat("remove.packages(\"promises\")\n")
  cat("install.packages(\"promises\")\n")
  cat("packageVersion(\"promises\")\n")
  cat("shiny::runApp('C:/Users/klavy/Downloads')\n\n")
  quit(save = "no")
}

# Carregar bibliotecas necessárias
library(shiny)
library(shinyjs)
library(DT)
library(shinyWidgets)
library(shinyFeedback)
library(bslib)
library(RSQLite)
library(DBI)

# Verificar se o arquivo app.R existe
if (!file.exists("app.R")) {
  stop("O arquivo app.R não foi encontrado no diretório atual.")
}

# Executar o aplicativo
cat("Acesse http://localhost:3838 no seu navegador\n")
cat("Pressione Ctrl+C para encerrar o aplicativo\n\n")

# Executar o aplicativo na porta 3838
runApp("app.R", host = "0.0.0.0", port = 3838) 