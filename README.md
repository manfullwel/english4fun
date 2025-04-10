# English Classes Website

Website para aulas de inglês com recurso de quiz interativo.

## Tecnologias Utilizadas

- HTML5
- CSS3
- JavaScript
- EmailJS para envio de emails
- Chart.js para gráficos
- Vercel para deploy

## Configuração do Ambiente

1. Clone o repositório
```bash
git clone [URL_DO_SEU_REPOSITÓRIO]
```

2. Instale as dependências
```bash
npm install
```

3. Configure as variáveis de ambiente
- Crie um arquivo `.env` na raiz do projeto
- Adicione suas credenciais do EmailJS:
```
EMAILJS_USER_ID=seu_user_id
```

## Deploy no Vercel

1. Instale o Vercel CLI globalmente
```bash
npm install -g vercel
```

2. Faça login no Vercel
```bash
vercel login
```

3. Deploy do projeto
```bash
vercel
```

4. Para deploy em produção
```bash
vercel --prod
```

## Estrutura do Projeto

- `index.html` - Página principal
- `styles.css` - Estilos CSS
- `script.js` - Lógica JavaScript
- `vercel.json` - Configuração do Vercel
- `package.json` - Dependências e scripts

## Funcionalidades

- Quiz interativo
- Formulário de contato com EmailJS
- Design responsivo
- Tema escuro
- Animações
- Gráficos de progresso

## Segurança

- O código JavaScript está ofuscado para dificultar a manipulação
- Implementação de limite diário de emails para evitar spam
- Validação de email e nome para evitar cadastros duplicados
- Rastreamento de visitantes para monitoramento

## Personalização

- Edite o arquivo `styles.css` para personalizar cores e estilos
- Modifique os preços e planos no arquivo `index.html`
- Ajuste as perguntas do quiz no arquivo `script.js`

## Suporte

Para suporte, entre em contato através do formulário no site ou envie um email para igorofyeshua@gmail.com 