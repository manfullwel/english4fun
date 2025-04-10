# Script para atualizar pacotes necessários
cat("Atualizando pacotes necessários...\n")

# Lista de pacotes necessários
packages <- c("shiny", "shinyjs", "DT", "shinyWidgets", "shinyFeedback", "bslib", "RSQLite", "DBI", "promises")

# Função para atualizar um pacote específico
update_package <- function(pkg) {
  cat("Verificando pacote:", pkg, "\n")
  
  # Verificar se o pacote está instalado
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("Instalando pacote:", pkg, "\n")
    install.packages(pkg)
  } else {
    # Verificar a versão atual
    current_version <- packageVersion(pkg)
    cat("Versão atual de", pkg, ":", as.character(current_version), "\n")
    
    # Para o pacote promises, verificar se precisa atualizar
    if (pkg == "promises" && current_version < "1.3.2") {
      cat("Atualizando promises para versão >= 1.3.2\n")
      install.packages("promises")
    }
  }
}

# Atualizar cada pacote
for (pkg in packages) {
  update_package(pkg)
}

cat("\nAtualização concluída. Agora você pode executar seu aplicativo Shiny.\n")
cat("Use o comando: shiny::runApp('C:/Users/klavy/Downloads')\n")

# Definir o diretório de trabalho
setwd("C:/Users/klavy/Downloads")

# Remover o pacote promises
remove.packages("promises")

# Instalar a versão mais recente
install.packages("promises")

# Verificar a versão instalada
packageVersion("promises")

# Executar o aplicativo
shiny::runApp('.')

# Para encerrar a sessão do R
cat("\nPara encerrar completamente o R e resolver o problema do pacote promises,\n")
cat("por favor, feche o RStudio completamente e abra novamente.\n")
cat("Depois execute o aplicativo com: shiny::runApp('C:/Users/klavy/Downloads')\n") 