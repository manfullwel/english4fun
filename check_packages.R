# Script para verificar se todos os pacotes necessários estão instalados e carregados corretamente
cat("Verificando pacotes necessários...\n\n")

# Lista de pacotes necessários
packages <- c("shiny", "shinyjs", "DT", "shinyWidgets", "shinyFeedback", "bslib", "RSQLite", "DBI", "promises")

# Verificar cada pacote
for (pkg in packages) {
  cat("Verificando pacote:", pkg, "\n")
  
  # Verificar se o pacote está instalado
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("  - Pacote não instalado. Instalando...\n")
    install.packages(pkg)
  } else {
    cat("  - Pacote instalado. Versão:", as.character(packageVersion(pkg)), "\n")
  }
  
  # Tentar carregar o pacote
  tryCatch({
    library(pkg, character.only = TRUE)
    cat("  - Pacote carregado com sucesso.\n")
  }, error = function(e) {
    cat("  - ERRO ao carregar o pacote:", e$message, "\n")
  })
  
  cat("\n")
}

cat("Verificação concluída.\n")
cat("Se todos os pacotes foram carregados com sucesso, você pode executar seu aplicativo.\n")
cat("Use o comando: shiny::runApp('C:/Users/klavy/Downloads')\n") 