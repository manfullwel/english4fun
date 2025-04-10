# Atualizar o pacote promises para a versão necessária
if (!require("promises")) {
  install.packages("promises")
} else {
  # Verificar a versão atual
  current_version <- packageVersion("promises")
  required_version <- "1.3.2"
  
  if (current_version < required_version) {
    message("Atualizando o pacote promises de ", current_version, " para ", required_version)
    install.packages("promises")
  } else {
    message("O pacote promises já está na versão necessária: ", current_version)
  }
} 