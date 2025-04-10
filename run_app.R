# Carregar bibliotecas necessárias
if (!require("shiny")) {
  install.packages("shiny")
}
library(shiny)

# Verificar se o arquivo app.R existe
if (!file.exists("app.R")) {
  stop("O arquivo app.R não foi encontrado no diretório atual.")
}

# Executar o aplicativo
cat("Iniciando o aplicativo Shiny...\n")
cat("Acesse http://localhost:3838 no seu navegador\n")
cat("Pressione Ctrl+C para encerrar o aplicativo\n\n")

# Executar o aplicativo na porta 3838
runApp("app.R", host = "0.0.0.0", port = 3838) 