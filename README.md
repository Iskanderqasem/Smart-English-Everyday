# 🌍 Smart English Everyday

<div align="center">

**AI-Powered English Learning Platform**

*Compete with Duolingo, Babbel, ELSA Speak & Busuu — with richer AI features*

[![Flutter](https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-green?logo=node.js)](https://nodejs.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql)](https://postgresql.org)
[![Redis](https://img.shields.io/badge/Redis-7-red?logo=redis)](https://redis.io)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://docker.com)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-black?logo=github)](/.github/workflows)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

[📱 Download APK](#installation) • [📖 API Docs](#api-documentation) • [🚀 Deploy](#deployment) • [🤝 Contributing](CONTRIBUTING.md)

</div>

---

## ✨ Features

### 🎓 AI-Powered Learning
- **AI Level Assessment** — Comprehensive CEFR evaluation (A1–C2) on first login
- **Personalized Learning Plan** — AI creates your unique study path
- **24/7 AI English Teacher** — Ask grammar, vocabulary, pronunciation questions anytime
- **AI Conversation Chatbot** — Practice real conversations across 8 topics
- **AI Writing Coach** — Get instant feedback, corrections, and improved versions
- **AI Speaking Analysis** — Pronunciation, fluency, accent, and confidence scoring

### 🌏 5 English Variants
| Variant | Features |
|---------|----------|
| 🇬🇧 United Kingdom | Pronunciation, spelling (colour/colour), RP accent |
| 🇺🇸 United States | American accent, US spelling, local expressions |
| 🇦🇺 Australia | Australian accent, slang, Strine expressions |
| 🇳🇿 New Zealand | Kiwi accent, NZ vocabulary, Māori loanwords |
| 🇨🇦 Canada | Canadian pronunciation, French influence, local idioms |

### 📚 10 Complete Learning Levels
1. **Level 1** — Alphabet, Phonics, Simple Words
2. **Level 2** — Simple Sentences, Greetings, Daily Vocabulary
3. **Level 3** — Beginner Conversation
4. **Level 4** — Elementary
5. **Level 5** — Intermediate
6. **Level 6** — Upper Intermediate
7. **Level 7** — Advanced
8. **Level 8** — Business English
9. **Level 9** — Academic English
10. **Level 10** — IELTS / TOEFL Preparation

### 🏆 Skills Coverage
- **Reading** — AI pronunciation scoring, word-by-word analysis
- **Writing** — AI essay scoring, grammar correction, style improvement
- **Speaking** — Accent analysis, fluency, confidence scoring
- **Listening** — Native speaker audio in 5 accents
- **Grammar** — 15+ topics from basics to advanced
- **Vocabulary** — 10,000+ words with spaced repetition

### 🎮 Games & Engagement
- Word Match, Hangman, Word Search, Crossword
- Sentence Builder, Memory Cards, Vocabulary Race
- Daily Challenges with leaderboards
- Streak system, badges, XP points

### 👥 Multi-Role Platform
- **Student Dashboard** — Progress, CEFR level, IELTS estimate
- **Parent Dashboard** — Monitor child's progress and time spent
- **Admin Dashboard** — Analytics, user management, reports
- **Teacher Dashboard** — Assign homework, track students

---

## 🛠 Tech Stack

### Frontend (Mobile)
- **Flutter 3.24** — Cross-platform iOS & Android
- **Flutter BLoC** — State management
- **Material Design 3** — Modern UI with dark/light mode
- **GoRouter** — Declarative navigation
- **Hive + Secure Storage** — Local & encrypted storage

### Backend
- **Node.js 20 + Express** — REST API & WebSocket
- **Sequelize ORM** — PostgreSQL models
- **Socket.io** — Real-time features
- **Bull** — Background job queues
- **Passport.js** — OAuth2 (Google, Facebook, Apple)
- **Speakeasy** — Two-factor authentication

### AI & Services
- **OpenAI GPT-4** — Writing analysis, grammar correction, tutoring
- **Google Cloud Speech** — Speech-to-Text, Text-to-Speech
- **Firebase** — Push notifications (FCM), Auth
- **AWS S3** — Audio & image storage

### Infrastructure
- **PostgreSQL 15** — Primary database
- **Redis 7** — Caching, sessions, queues
- **Docker + Nginx** — Containerized deployment
- **GitHub Actions** — CI/CD pipeline
- **AWS** — EC2, RDS, ElastiCache, S3, CloudFront

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.24+ with Dart 3.4+
- Node.js 20+
- PostgreSQL 15+
- Redis 7+
- Docker & Docker Compose (optional but recommended)

### 1. Clone the Repository
```bash
git clone https://github.com/Iskanderqasem/Smart-English-Everyday.git
cd Smart-English-Everyday
```

### 2. Backend Setup
```bash
cd backend
cp .env.example .env
# Edit .env with your API keys
npm install
```

### 3. Database Setup
```bash
# Run migrations
psql -U your_user -d see_db -f database/migrations/001_create_users.sql
# ... run all migrations in order
# Seed data
psql -U your_user -d see_db -f database/seeds/001_seed_levels.sql
```

### 4. Start Backend
```bash
npm run dev
```

### 5. Flutter Setup
```bash
cd mobile
flutter pub get
flutter run
```

### 🐳 Docker Quick Start (Recommended)
```bash
cp .env.example .env
# Edit .env with your keys
docker-compose up -d
```

The API will be available at `http://localhost:5000` and API docs at `http://localhost:5000/api/docs`

---

## 📱 Installation (APK)

### Android APK
1. Go to [Releases](https://github.com/Iskanderqasem/Smart-English-Everyday/releases)
2. Download `app-release.apk`
3. Enable "Install from unknown sources" on your Android device
4. Install the APK

### QR Code
Scan the QR code from the latest release to download directly:

> QR code is generated automatically on each release

---

## 📖 API Documentation

Interactive API docs available at:
- **Development:** `http://localhost:5000/api/docs`
- **Production:** `https://api.smartenglisheveryday.com/api/docs`

### Key Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new student |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/google` | Google OAuth login |
| POST | `/api/assessment/complete` | Submit full AI assessment |
| GET | `/api/levels` | Get all levels with progress |
| POST | `/api/writing/submit` | AI writing analysis |
| POST | `/api/speaking/session/submit` | AI speaking analysis |
| POST | `/api/ai-teacher/message` | Chat with AI teacher |
| GET | `/api/progress/summary` | Student progress dashboard |
| GET | `/api/admin/dashboard` | Admin stats |

---

## 🗄 Database Schema

See [docs/architecture/ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md) for the complete ER diagram.

**Key Tables:**
- `users` — Students, parents, teachers, admins
- `levels` — 10 learning levels
- `lessons` — Lessons within each level
- `words` — 10,000+ vocabulary words
- `progress` — Per-user learning progress
- `assessments` — AI assessment results
- `speaking_sessions` / `reading_sessions` / `writing_submissions`
- `achievements` / `user_achievements`
- `chat_messages` — AI teacher & chatbot history

---

## 🚢 Deployment

### AWS Production Setup
See [docs/guides/DEPLOYMENT.md](docs/guides/DEPLOYMENT.md) for complete AWS deployment guide covering:
- EC2 instance setup
- RDS PostgreSQL
- ElastiCache Redis
- S3 + CloudFront CDN
- SSL certificate (ACM)
- Route 53 DNS

### Environment Variables
See [docs/guides/ENVIRONMENT.md](docs/guides/ENVIRONMENT.md) for all required environment variables.

---

## 🔒 Security

- **JWT** — Access & refresh token authentication
- **bcrypt** — Password hashing (12 rounds)
- **HTTPS** — TLS 1.2/1.3 enforced
- **2FA** — TOTP-based two-factor authentication
- **Rate Limiting** — Per-IP request limiting
- **CORS** — Whitelisted origins only
- **Helmet.js** — Security headers
- **Input Validation** — Joi schema validation on all inputs
- **SQL Injection Prevention** — Sequelize parameterized queries
- **Role-Based Access** — Admin, Teacher, Parent, Student roles

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit: `git commit -m 'feat: add amazing feature'`
4. Push: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Iskanderqasem**
- GitHub: [@Iskanderqasem](https://github.com/Iskanderqasem)
- Email: iskanderqasem@gmail.com

---

<div align="center">
Made with ❤️ for English learners worldwide
</div>
