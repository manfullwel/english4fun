# Script para verificar a versão do pacote promises
cat("Verificando a versão do pacote promises...\n\n")

# Verificar se o pacote promises está instalado
if (!requireNamespace("promises", quietly = TRUE)) {
  cat("O pacote promises não está instalado.\n")
  cat("Instalando o pacote promises...\n")
  install.packages("promises")
} else {
  # Verificar a versão atual
  current_version <- packageVersion("promises")
  cat("Versão atual do pacote promises:", as.character(current_version), "\n")
  
  # Verificar se a versão é suficiente
  if (current_version < "1.3.2") {
    cat("A versão atual do pacote promises é menor que 1.3.2.\n")
    cat("Para resolver este problema, você precisa:\n\n")
    cat("1. Feche completamente o RStudio (clique no X para fechar a janela)\n")
    cat("2. Abra o RStudio novamente\n")
    cat("3. Execute os seguintes comandos:\n\n")
    cat("remove.packages(\"promises\")\n")
    cat("install.packages(\"promises\")\n")
    cat("packageVersion(\"promises\")\n")
    cat("shiny::runApp('C:/Users/klavy/Downloads')\n\n")
  } else {
    cat("A versão do pacote promises é suficiente (>= 1.3.2).\n")
    cat("Você pode executar seu aplicativo com:\n\n")
    cat("shiny::runApp('C:/Users/klavy/Downloads')\n\n")
  }
}

cat("Se você ainda tiver problemas, tente reiniciar o computador e depois executar os comandos acima.\n")
cat("Isso garantirá que todos os processos do R sejam encerrados e você possa instalar a versão correta do pacote promises.\n") 