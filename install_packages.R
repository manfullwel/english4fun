# Lista de pacotes necessários
packages <- c("shiny", "shinyjs", "DT", "shinyWidgets", "shinyFeedback", "bslib", "RSQLite", "DBI")

# Função para instalar pacotes que não estão instalados
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    message("Instalando pacotes: ", paste(new_packages, collapse = ", "))
    install.packages(new_packages)
  } else {
    message("Todos os pacotes já estão instalados!")
  }
}

# Instalar pacotes faltantes
install_if_missing(packages) 