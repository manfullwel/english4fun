// Quiz data
const quizData = {
    basic: [
        {
            question: "What is the correct form of 'to be' for 'I'?",
            options: ["am", "is", "are", "be"],
            correct: 0
        },
        {
            question: "Choose the correct sentence:",
            options: [
                "I have a car blue",
                "I have a blue car",
                "I blue have a car",
                "I car have a blue"
            ],
            correct: 1
        },
        {
            question: "What is the plural of 'child'?",
            options: ["childs", "children", "childes", "child's"],
            correct: 1
        }
    ],
    intermediate: [
        {
            question: "Which sentence uses the present perfect correctly?",
            options: [
                "I have been to Paris last year",
                "I have never been to Paris",
                "I have go to Paris tomorrow",
                "I have went to Paris"
            ],
            correct: 1
        },
        {
            question: "Choose the correct conditional sentence:",
            options: [
                "If I will see him, I tell him",
                "If I see him, I will tell him",
                "If I seen him, I would tell him",
                "If I saw him, I had told him"
            ],
            correct: 1
        },
        {
            question: "Which sentence is in the passive voice?",
            options: [
                "The cat chased the mouse",
                "The mouse was chased by the cat",
                "The mouse chased the cat",
                "The cat was chasing the mouse"
            ],
            correct: 1
        }
    ],
    advanced: [
        {
            question: "Which sentence demonstrates correct use of the subjunctive mood?",
            options: [
                "I wish I was there",
                "I wish I were there",
                "I wish I would be there",
                "I wish I am there"
            ],
            correct: 1
        },
        {
            question: "Identify the correct usage of inversion:",
            options: [
                "Never I have seen such beauty",
                "Never have I seen such beauty",
                "Never did I saw such beauty",
                "Never I saw such beauty"
            ],
            correct: 1
        },
        {
            question: "Choose the correct phrasal verb:",
            options: [
                "I need to look up this word",
                "I need to look this word up",
                "I need to look up it",
                "I need to look it up"
            ],
            correct: 3
        }
    ]
};

// Quiz state management
class QuizState {
    constructor() {
        this.currentQuiz = null;
        this.currentQuestion = 0;
        this.score = 0;
        this.selectedLevel = '';
        this.quizHistory = this.loadQuizHistory();
    }

    loadQuizHistory() {
        try {
            const history = localStorage.getItem('quizHistory');
            return history ? JSON.parse(history) : [];
        } catch (error) {
            console.error('Error loading quiz history:', error);
            return [];
        }
    }

    saveQuizHistory() {
        try {
            localStorage.setItem('quizHistory', JSON.stringify(this.quizHistory));
        } catch (error) {
            console.error('Error saving quiz history:', error);
        }
    }

    addQuizResult(level, score) {
        this.quizHistory.push({
            level,
            score,
            date: new Date().toISOString()
        });
        this.saveQuizHistory();
    }

    reset() {
        this.currentQuiz = null;
        this.currentQuestion = 0;
        this.score = 0;
        this.selectedLevel = '';
    }
}

// Quiz UI management
class QuizUI {
    constructor(quizState) {
        this.quizState = quizState;
        this.initializeElements();
        this.bindEvents();
    }

    initializeElements() {
        this.startQuizBtn = document.getElementById('startQuiz');
        this.quizLevelSelect = document.getElementById('quizLevel');
        this.quizStart = document.getElementById('quizStart');
        this.quizContent = document.getElementById('quizContent');
        this.quizResult = document.getElementById('quizResult');
        this.questionEl = document.getElementById('question');
        this.optionsEl = document.getElementById('options');
        this.nextQuestionBtn = document.getElementById('nextQuestion');
        this.retakeQuizBtn = document.getElementById('retakeQuiz');
        this.scoreEl = document.getElementById('score');
        this.resultMessageEl = document.getElementById('resultMessage');
        this.progressBar = document.querySelector('.progress-bar');
    }

    bindEvents() {
        this.startQuizBtn.addEventListener('click', () => this.startQuiz());
        this.nextQuestionBtn.addEventListener('click', () => this.nextQuestion());
        this.retakeQuizBtn.addEventListener('click', () => this.retakeQuiz());
    }

    startQuiz() {
        const selectedLevel = this.quizLevelSelect.value;
        if (!selectedLevel) {
            this.showError('Por favor, selecione um nível para começar.');
            return;
        }

        this.quizState.reset();
        this.quizState.selectedLevel = selectedLevel;
        this.quizState.currentQuiz = quizData[selectedLevel];
        
        this.quizStart.style.display = 'none';
        this.quizContent.style.display = 'block';
        this.showQuestion();
    }

    showQuestion() {
        const questionData = this.quizState.currentQuiz[this.quizState.currentQuestion];
        this.progressBar.style.width = `${(this.quizState.currentQuestion / this.quizState.currentQuiz.length) * 100}%`;
        this.questionEl.textContent = questionData.question;
        this.optionsEl.innerHTML = '';
        
        questionData.options.forEach((option, index) => {
            const button = document.createElement('button');
            button.className = 'btn btn-outline-light mb-2';
            button.textContent = option;
            button.addEventListener('click', () => this.selectAnswer(index));
            this.optionsEl.appendChild(button);
        });
        
        this.nextQuestionBtn.style.display = 'none';
    }

    selectAnswer(index) {
        const buttons = this.optionsEl.querySelectorAll('.btn');
        buttons.forEach(button => {
            button.disabled = true;
            button.classList.remove('btn-success', 'btn-danger');
        });
        
        const correct = this.quizState.currentQuiz[this.quizState.currentQuestion].correct;
        buttons[correct].classList.add('btn-success');
        
        if (index === correct) {
            this.quizState.score++;
            buttons[index].classList.add('btn-success');
        } else {
            buttons[index].classList.add('btn-danger');
        }
        
        if (this.quizState.currentQuestion < this.quizState.currentQuiz.length - 1) {
            this.nextQuestionBtn.style.display = 'block';
        } else {
            setTimeout(() => this.showResult(), 1500);
        }
    }

    nextQuestion() {
        this.quizState.currentQuestion++;
        if (this.quizState.currentQuestion < this.quizState.currentQuiz.length) {
            this.showQuestion();
        } else {
            this.showResult();
        }
    }

    showResult() {
        this.quizContent.style.display = 'none';
        this.quizResult.style.display = 'block';
        
        const finalScore = (this.quizState.score / this.quizState.currentQuiz.length) * 100;
        this.scoreEl.textContent = finalScore.toFixed(0);
        
        let message = '';
        if (finalScore >= 80) {
            message = 'Excelente! Você está muito bem neste nível!';
        } else if (finalScore >= 60) {
            message = 'Bom trabalho! Mas ainda há espaço para melhorar.';
        } else {
            message = 'Continue praticando! Que tal agendar uma aula experimental?';
        }
        
        this.resultMessageEl.textContent = message;
        this.quizState.addQuizResult(this.quizState.selectedLevel, finalScore);
    }

    retakeQuiz() {
        this.quizResult.style.display = 'none';
        this.quizStart.style.display = 'block';
        this.quizLevelSelect.value = '';
    }

    showError(message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'alert alert-danger mt-3';
        errorDiv.textContent = message;
        this.quizStart.appendChild(errorDiv);
        setTimeout(() => errorDiv.remove(), 3000);
    }
}

// Initialize quiz when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    const quizState = new QuizState();
    const quizUI = new QuizUI(quizState);
});