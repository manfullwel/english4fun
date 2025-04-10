// Wait for the DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Bootstrap tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Initialize Bootstrap popovers
    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });

    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                const navbarHeight = document.querySelector('.navbar-custom').offsetHeight;
                const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - navbarHeight;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
                
                // Close mobile menu if open
                const navbarToggler = document.querySelector('.navbar-toggler');
                if (navbarToggler && !navbarToggler.classList.contains('collapsed')) {
                    navbarToggler.click();
                }
            }
        });
    });

    // Navbar background change on scroll
    const navbar = document.querySelector('.navbar-custom');
    window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
            navbar.style.backgroundColor = 'rgba(26, 26, 26, 0.95)';
            navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.3)';
        } else {
            navbar.style.backgroundColor = 'rgba(26, 26, 26, 0.9)';
            navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.3)';
        }
    });

    // Admin Panel Toggle
    const adminToggle = document.querySelector('.admin-toggle');
    const adminPanel = document.querySelector('.admin-panel');
    
    if (adminToggle && adminPanel) {
        adminToggle.addEventListener('click', function() {
            adminPanel.style.display = adminPanel.style.display === 'block' ? 'none' : 'block';
        });
    }

    // Exit Intent Modal
    let exitIntentShown = false;
    const exitIntentModal = new bootstrap.Modal(document.getElementById('exitIntentModal'));
    
    document.addEventListener('mouseout', function(e) {
        if (!exitIntentShown && e.clientY <= 0) {
            exitIntentModal.show();
            exitIntentShown = true;
        }
    });

    // Email validation helper function
    function isValidEmail(email) {
        const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(String(email).toLowerCase());
    }

    // Initialize Charts
    const ctx = document.getElementById('progressChart');
    if (ctx) {
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Semana 1', 'Semana 2', 'Semana 3', 'Semana 4', 'Semana 5', 'Semana 6'],
                datasets: [{
                    label: 'Progresso do Aluno',
                    data: [65, 70, 75, 82, 88, 95],
                    borderColor: '#00bc8c',
                    backgroundColor: 'rgba(0, 188, 140, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            color: '#eee'
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100,
                        ticks: {
                            color: '#ccc'
                        },
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#ccc'
                        },
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        }
                    }
                }
            }
        });
    }

    // Animate elements on scroll
    const animateOnScroll = function() {
        const elements = document.querySelectorAll('.animate-on-scroll');
        
        elements.forEach(element => {
            const elementPosition = element.getBoundingClientRect().top;
            const windowHeight = window.innerHeight;
            
            if (elementPosition < windowHeight - 100) {
                element.classList.add('animated');
            }
        });
    };

    window.addEventListener('scroll', animateOnScroll);
    animateOnScroll(); // Initial check

    // WhatsApp Button Click Handler
    const whatsappButton = document.querySelector('.floating-whatsapp .btn');
    if (whatsappButton) {
        whatsappButton.addEventListener('click', function() {
            const phoneNumber = '5511999999999'; // Replace with your actual WhatsApp number
            const message = 'Olá! Gostaria de saber mais sobre as aulas de inglês.';
            const whatsappUrl = `https://wa.me/${phoneNumber}?text=${encodeURIComponent(message)}`;
            window.open(whatsappUrl, '_blank');
        });
    }

    // Add loading animation to buttons
    document.querySelectorAll('.btn').forEach(button => {
        button.addEventListener('click', function() {
            if (this.classList.contains('btn-loading')) {
                const originalText = this.innerHTML;
                this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Carregando...';
                this.disabled = true;
                
                // Simulate loading (remove in production)
                setTimeout(() => {
                    this.innerHTML = originalText;
                    this.disabled = false;
                }, 1500);
            }
        });
    });

    // Quiz System
    class QuizSystem {
        constructor() {
            this.questions = {
                basic: [
                    {
                        question: "What is the correct way to say 'Hello' in English?",
                        options: ["Hola", "Hello", "Bonjour", "Ciao"],
                        correct: 1
                    },
                    {
                        question: "Which word means 'House' in English?",
                        options: ["Casa", "House", "Maison", "Haus"],
                        correct: 1
                    }
                ],
                intermediate: [
                    {
                        question: "Choose the correct sentence:",
                        options: [
                            "I am going to the store yesterday",
                            "I went to the store yesterday",
                            "I go to the store yesterday",
                            "I going to the store yesterday"
                        ],
                        correct: 1
                    }
                ],
                advanced: [
                    {
                        question: "Select the sentence with correct subject-verb agreement:",
                        options: [
                            "The team are playing well",
                            "The team is playing well",
                            "The teams is playing well",
                            "The teams are playing well"
                        ],
                        correct: 1
                    }
                ]
            };
            
            this.currentLevel = 'basic';
            this.currentQuestion = 0;
            this.score = 0;
            
            this.initializeQuiz();
        }
        
        initializeQuiz() {
            const quizContainer = document.getElementById('quiz-container');
            if (!quizContainer) return;
            
            this.displayQuestion();
            this.updateProgress();
        }
        
        displayQuestion() {
            const quizContainer = document.getElementById('quiz-container');
            const question = this.questions[this.currentLevel][this.currentQuestion];
            
            if (!question) {
                this.showResults();
                return;
            }
            
            let html = `
                <h3 class="mb-4">${question.question}</h3>
                <div class="options">
            `;
            
            question.options.forEach((option, index) => {
                html += `
                    <button class="btn btn-outline-primary option-btn mb-3" 
                            onclick="quizSystem.checkAnswer(${index})">
                        ${option}
                    </button>
                `;
            });
            
            html += '</div>';
            quizContainer.innerHTML = html;
        }
        
        checkAnswer(selectedIndex) {
            const question = this.questions[this.currentLevel][this.currentQuestion];
            const buttons = document.querySelectorAll('.option-btn');
            
            buttons.forEach(btn => btn.disabled = true);
            
            if (selectedIndex === question.correct) {
                buttons[selectedIndex].classList.remove('btn-outline-primary');
                buttons[selectedIndex].classList.add('btn-success');
                this.score++;
            } else {
                buttons[selectedIndex].classList.remove('btn-outline-primary');
                buttons[selectedIndex].classList.add('btn-danger');
                buttons[question.correct].classList.remove('btn-outline-primary');
                buttons[question.correct].classList.add('btn-success');
            }
            
            setTimeout(() => {
                this.currentQuestion++;
                this.displayQuestion();
                this.updateProgress();
            }, 1500);
        }
        
        updateProgress() {
            const progressBar = document.querySelector('.progress-bar');
            if (!progressBar) return;
            
            const totalQuestions = this.questions[this.currentLevel].length;
            const progress = (this.currentQuestion / totalQuestions) * 100;
            progressBar.style.width = `${progress}%`;
            progressBar.setAttribute('aria-valuenow', progress);
        }
        
        showResults() {
            const quizContainer = document.getElementById('quiz-container');
            const totalQuestions = this.questions[this.currentLevel].length;
            const percentage = (this.score / totalQuestions) * 100;
            
            let message = '';
            if (percentage >= 80) {
                message = 'Excellent! You have a good understanding of this level.';
            } else if (percentage >= 60) {
                message = 'Good job! Keep practicing to improve your skills.';
            } else {
                message = 'Keep studying! You need more practice with this level.';
            }
            
            quizContainer.innerHTML = `
                <div class="text-center">
                    <h3>Quiz Complete!</h3>
                    <p>Your score: ${this.score}/${totalQuestions} (${percentage}%)</p>
                    <p>${message}</p>
                    <button class="btn btn-primary mt-3" onclick="quizSystem.restartQuiz()">
                        Try Again
                    </button>
                </div>
            `;
        }
        
        restartQuiz() {
            this.currentQuestion = 0;
            this.score = 0;
            this.initializeQuiz();
        }
    }

    // Form Submission and Email
    class FormHandler {
        constructor() {
            this.form = document.getElementById('contact-form');
            this.initializeForm();
            this.contacts = this.loadContacts();
            this.visitors = this.loadVisitors();
            this.dailyEmailCount = this.loadDailyEmailCount();
            this.lastEmailDate = this.loadLastEmailDate();
            
            // Verificar limite diário de emails
            this.checkDailyEmailLimit();
        }
        
        loadContacts() {
            try {
                return JSON.parse(localStorage.getItem('contacts') || '[]');
            } catch (error) {
                console.error('Error loading contacts:', error);
                return [];
            }
        }
        
        saveContacts() {
            try {
                localStorage.setItem('contacts', JSON.stringify(this.contacts));
            } catch (error) {
                console.error('Error saving contacts:', error);
            }
        }
        
        loadVisitors() {
            try {
                return JSON.parse(localStorage.getItem('visitors') || '[]');
            } catch (error) {
                console.error('Error loading visitors:', error);
                return [];
            }
        }
        
        saveVisitors() {
            try {
                localStorage.setItem('visitors', JSON.stringify(this.visitors));
            } catch (error) {
                console.error('Error saving visitors:', error);
            }
        }
        
        loadDailyEmailCount() {
            try {
                return parseInt(localStorage.getItem('dailyEmailCount') || '0');
            } catch (error) {
                console.error('Error loading daily email count:', error);
                return 0;
            }
        }
        
        saveDailyEmailCount() {
            try {
                localStorage.setItem('dailyEmailCount', this.dailyEmailCount.toString());
            } catch (error) {
                console.error('Error saving daily email count:', error);
            }
        }
        
        loadLastEmailDate() {
            try {
                return localStorage.getItem('lastEmailDate') || '';
            } catch (error) {
                console.error('Error loading last email date:', error);
                return '';
            }
        }
        
        saveLastEmailDate() {
            try {
                localStorage.setItem('lastEmailDate', this.lastEmailDate);
            } catch (error) {
                console.error('Error saving last email date:', error);
            }
        }
        
        checkDailyEmailLimit() {
            const today = new Date().toDateString();
            
            // Se for um novo dia, resetar o contador
            if (this.lastEmailDate !== today) {
                this.dailyEmailCount = 0;
                this.lastEmailDate = today;
                this.saveDailyEmailCount();
                this.saveLastEmailDate();
            }
        }
        
        initializeForm() {
            if (!this.form) return;
            
            this.form.addEventListener('submit', (e) => {
                e.preventDefault();
                this.handleSubmit();
            });
            
            // Registrar visitante
            this.registerVisitor();
        }
        
        registerVisitor() {
            const visitorId = this.generateVisitorId();
            const timestamp = new Date().toISOString();
            const userAgent = navigator.userAgent;
            const screenResolution = `${window.screen.width}x${window.screen.height}`;
            const language = navigator.language;
            
            const visitor = {
                id: visitorId,
                timestamp,
                userAgent,
                screenResolution,
                language
            };
            
            this.visitors.push(visitor);
            this.saveVisitors();
            
            // Enviar alerta de visitante (se dentro do limite diário)
            if (this.dailyEmailCount < 10) {
                this.sendVisitorAlert(visitor);
            }
        }
        
        generateVisitorId() {
            // Gerar ID único para o visitante
            return 'v' + Date.now() + Math.random().toString(36).substr(2, 9);
        }
        
        async sendVisitorAlert(visitor) {
            try {
                await emailjs.send(
                    "service_jmprh8h",
                    "template_1oduolk",
                    {
                        to_email: "igorofyeshua@gmail.com",
                        from_name: "Sistema de Alerta",
                        from_email: "sistema@alerta.com",
                        message: `Novo visitante detectado!\n\nID: ${visitor.id}\nData/Hora: ${visitor.timestamp}\nNavegador: ${visitor.userAgent}\nResolução: ${visitor.screenResolution}\nIdioma: ${visitor.language}`,
                        date: new Date().toLocaleString()
                    }
                );
                
                this.dailyEmailCount++;
                this.saveDailyEmailCount();
            } catch (error) {
                console.error('Error sending visitor alert:', error);
            }
        }
        
        validateEmail(email) {
            const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            return re.test(String(email).toLowerCase());
        }
        
        validateName(name) {
            return name.trim().length >= 3 && /^[a-zA-ZÀ-ÿ\s]*$/.test(name);
        }
        
        isDuplicate(email, name) {
            return this.contacts.some(contact => 
                contact.email.toLowerCase() === email.toLowerCase() || 
                contact.name.toLowerCase() === name.toLowerCase()
            );
        }
        
        async handleSubmit() {
            const name = this.form.querySelector('[name="name"]').value.trim();
            const email = this.form.querySelector('[name="email"]').value.trim();
            const message = this.form.querySelector('[name="message"]').value.trim();
            
            // Validações
            if (!this.validateName(name)) {
                this.showErrorMessage('Por favor, insira um nome válido (apenas letras e espaços)');
                return;
            }
            
            if (!this.validateEmail(email)) {
                this.showErrorMessage('Por favor, insira um email válido');
                return;
            }
            
            if (this.isDuplicate(email, name)) {
                this.showErrorMessage('Este email ou nome já está cadastrado');
                return;
            }
            
            // Verificar limite diário de emails
            if (this.dailyEmailCount >= 10) {
                this.showErrorMessage('Limite diário de cadastros atingido. Por favor, tente novamente amanhã.');
                return;
            }
            
            const formData = {
                name,
                email,
                message,
                date: new Date().toISOString()
            };
            
            try {
                // Salva no localStorage
                this.contacts.push(formData);
                this.saveContacts();
                
                // Envia email
                await this.sendEmail(formData);
                this.showSuccessMessage();
                this.form.reset();
            } catch (error) {
                this.showErrorMessage('Erro ao enviar mensagem. Por favor, tente novamente.');
                console.error('Error:', error);
            }
        }
        
        async sendEmail(formData) {
            return new Promise((resolve, reject) => {
                emailjs.send(
                    "service_jmprh8h",
                    "template_1oduolk",
                    {
                        to_email: "igorofyeshua@gmail.com",
                        from_name: formData.name,
                        from_email: formData.email,
                        message: formData.message,
                        date: new Date().toLocaleString()
                    }
                )
                .then(response => {
                    this.dailyEmailCount++;
                    this.saveDailyEmailCount();
                    resolve(response);
                })
                .catch(error => reject(error));
            });
        }
        
        showSuccessMessage() {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-success mt-3';
            alertDiv.textContent = 'Cadastro realizado com sucesso! Entraremos em contato em breve.';
            this.form.appendChild(alertDiv);
            
            setTimeout(() => alertDiv.remove(), 5000);
        }
        
        showErrorMessage(message) {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-danger mt-3';
            alertDiv.textContent = message;
            this.form.appendChild(alertDiv);
            
            setTimeout(() => alertDiv.remove(), 5000);
        }
    }

    // Initialize quiz and form
    window.quizSystem = new QuizSystem();
    new FormHandler();
}); 