-- Seed: 001_seed_levels.sql
-- Description: Seed 10 proficiency levels mapping to CEFR
-- Created: 2024-01-01

BEGIN;

INSERT INTO levels (
    level_number, name, display_name, description, short_description,
    cefr_equivalent, required_xp, xp_to_next_level,
    color_hex, color_gradient_start, color_gradient_end,
    icon_name, unlock_message,
    estimated_hours, features_unlocked, topics, grammar_focus, skills_focus,
    min_accuracy_percent, sort_order
) VALUES

-- Level 1: Absolute Beginner (A1)
(
    1, 'beginner', 'Level 1 - Absolute Beginner',
    'Start your English journey from zero. Learn basic greetings, numbers, colors, and everyday objects. Perfect for those with no prior English knowledge.',
    'Greetings, numbers, colors & everyday words',
    'A1', 0, 500,
    '#FF6B6B', '#FF8E8E', '#FF4848',
    'star_outline',
    'Welcome to Smart English Everyday! Your journey to fluency begins now. 🎉',
    20,
    ARRAY['basic_lessons', 'vocabulary_cards', 'pronunciation_guide', 'daily_reminders'],
    ARRAY['greetings', 'numbers', 'colors', 'family', 'body_parts', 'days_weeks', 'weather', 'food_basics'],
    ARRAY['am/is/are', 'simple present', 'basic articles', 'singular/plural', 'this/that'],
    ARRAY['listening', 'vocabulary', 'reading'],
    70, 1
),

-- Level 2: Elementary (A1+)
(
    2, 'elementary', 'Level 2 - Elementary',
    'Build on your basics with simple sentences, common verbs, and everyday situations. Learn to introduce yourself and talk about your daily routine.',
    'Simple sentences & daily routines',
    'A1', 500, 1000,
    '#FF9F43', '#FFB366', '#FF8C1A',
    'star_half',
    'Excellent! You''ve mastered the basics. Now let''s build real sentences!',
    30,
    ARRAY['speaking_exercises', 'sentence_builder', 'word_matching'],
    ARRAY['home', 'school', 'shopping', 'transport', 'time', 'hobbies', 'animals', 'clothes'],
    ARRAY['simple present tense', 'have/has', 'can/can''t', 'possessive pronouns', 'prepositions of place'],
    ARRAY['speaking', 'vocabulary', 'listening', 'reading'],
    70, 2
),

-- Level 3: Pre-Intermediate (A2)
(
    3, 'pre_intermediate', 'Level 3 - Pre-Intermediate',
    'Expand your communication skills with past tense, question formation, and expressing opinions. Start having simple conversations about familiar topics.',
    'Past tense, questions & opinions',
    'A2', 1500, 1500,
    '#FECA57', '#FEDB7A', '#FEB923',
    'star',
    'You''re making great progress! Simple conversations are now within reach.',
    40,
    ARRAY['conversation_practice', 'audio_exercises', 'writing_basics', 'reading_short_texts'],
    ARRAY['travel', 'health', 'technology_basic', 'entertainment', 'sports', 'relationships', 'jobs'],
    ARRAY['past simple', 'past continuous', 'going to future', 'comparatives', 'superlatives', 'question words'],
    ARRAY['reading', 'writing', 'speaking', 'listening', 'vocabulary'],
    72, 3
),

-- Level 4: Intermediate Low (A2+)
(
    4, 'intermediate_low', 'Level 4 - Intermediate Low',
    'Bridge the gap between beginner and intermediate. Express yourself more freely on familiar topics, understand more complex texts, and use a wider range of vocabulary.',
    'Wider vocabulary & more complex sentences',
    'A2', 3000, 2000,
    '#48DBFB', '#7DE8FC', '#14CFF8',
    'shield_outline',
    'Outstanding! You can now handle most everyday situations in English.',
    50,
    ARRAY['reading_comprehension', 'writing_paragraphs', 'advanced_vocabulary', 'pronunciation_focus'],
    ARRAY['environment', 'culture', 'media', 'business_basic', 'science_basic', 'cities', 'nature'],
    ARRAY['present perfect', 'used to', 'modal verbs', 'if clauses type 1', 'passive voice intro'],
    ARRAY['reading', 'writing', 'speaking', 'grammar', 'vocabulary'],
    73, 4
),

-- Level 5: Intermediate (B1)
(
    5, 'intermediate', 'Level 5 - Intermediate',
    'Reach the internationally recognized B1 level. Understand the main points of clear standard speech, deal with most travel situations, and produce simple connected text.',
    'Clear communication on familiar topics',
    'B1', 5000, 2500,
    '#1DD1A1', '#4DDDBB', '#0DB87B',
    'shield_half',
    'Incredible achievement! You''ve reached B1 - the global communication standard!',
    60,
    ARRAY['essay_writing', 'debate_exercises', 'news_reading', 'podcast_listening', 'ai_conversation'],
    ARRAY['global_issues', 'psychology', 'history', 'economics_basic', 'arts', 'philosophy_intro', 'health_advanced'],
    ARRAY['past perfect', 'future perfect', 'if clauses type 2', 'reported speech', 'relative clauses'],
    ARRAY['writing', 'speaking', 'reading', 'listening', 'grammar'],
    75, 5
),

-- Level 6: Intermediate High (B1+)
(
    6, 'intermediate_high', 'Level 6 - Intermediate High',
    'Strengthen your B1 skills and approach B2. Express yourself with greater fluency and spontaneity, understand wider range of texts, and use language more flexibly.',
    'Fluency & flexibility in communication',
    'B1', 7500, 3000,
    '#54A0FF', '#7DB8FF', '#2F86FF',
    'shield',
    'You''re now highly competent in everyday English. B2 is just around the corner!',
    70,
    ARRAY['advanced_writing', 'debate_club', 'academic_reading', 'ielts_practice_basic'],
    ARRAY['politics', 'economics', 'science', 'literature', 'philosophy', 'digital_world', 'ethics'],
    ARRAY['advanced modals', 'mixed conditionals', 'inversion', 'cleft sentences', 'noun clauses'],
    ARRAY['writing', 'speaking', 'reading', 'grammar', 'listening'],
    75, 6
),

-- Level 7: Upper-Intermediate (B2)
(
    7, 'upper_intermediate', 'Level 7 - Upper Intermediate',
    'Achieve B2 proficiency - understand the main ideas of complex text, interact with native speakers fluently, and produce clear detailed text on a wide range of subjects.',
    'Complex texts & fluent interaction',
    'B2', 10500, 3500,
    '#A29BFE', '#C0B9FE', '#7B72FE',
    'diamond_outline',
    'AMAZING! B2 achieved! You can now thrive in international environments!',
    80,
    ARRAY['academic_writing', 'ielts_prep', 'toefl_prep', 'advanced_ai_tutor', 'native_content'],
    ARRAY['law', 'medicine_overview', 'technology_advanced', 'finance', 'research', 'culture_deep', 'critical_thinking'],
    ARRAY['subjunctive', 'advanced passive', 'discourse markers', 'hedging language', 'emphasis structures'],
    ARRAY['academic_writing', 'critical_thinking', 'speaking', 'reading', 'grammar'],
    78, 7
),

-- Level 8: Advanced (C1)
(
    8, 'advanced', 'Level 8 - Advanced',
    'Approach C1 mastery. Understand a wide range of demanding texts, express ideas fluently and spontaneously without much obvious searching for expressions.',
    'Fluent expression & demanding texts',
    'C1', 14000, 4000,
    '#FD79A8', '#FD9ABF', '#FC5490',
    'diamond_half',
    'You''re among the top English learners! C1 mastery is yours to claim!',
    90,
    ARRAY['professional_writing', 'academic_research', 'ielts_advanced', 'native_podcasts', 'idioms_advanced'],
    ARRAY['academic_disciplines', 'professional_communication', 'cultural_nuance', 'advanced_literature', 'global_affairs'],
    ARRAY['advanced discourse', 'pragmatic language', 'stylistic variation', 'idiomatic expression', 'collocations advanced'],
    ARRAY['academic_writing', 'professional_speaking', 'critical_reading', 'grammar_mastery'],
    80, 8
),

-- Level 9: Proficient (C1+)
(
    9, 'proficient', 'Level 9 - Proficient',
    'Near-native proficiency. Use language fluently, accurately, and effectively in complex situations. Understand virtually everything heard or read with exceptional nuance.',
    'Near-native fluency & accuracy',
    'C2', 18000, 5000,
    '#6C5CE7', '#8E7FF0', '#4A39E0',
    'diamond',
    'Elite level achieved! You communicate with near-native precision and style!',
    100,
    ARRAY['creative_writing', 'academic_papers', 'c2_exam_prep', 'culture_mastery', 'native_idioms'],
    ARRAY['literary_analysis', 'advanced_research', 'professional_mastery', 'cultural_deep_dive', 'language_metalinguistics'],
    ARRAY['advanced rhetoric', 'academic register', 'professional register', 'creative language', 'pragmatic competence'],
    ARRAY['professional_writing', 'native_speaking', 'academic_mastery', 'cultural_fluency'],
    82, 9
),

-- Level 10: Master (C2)
(
    10, 'master', 'Level 10 - Master',
    'Complete C2 mastery - the highest CEFR level. Understand everything with ease, express yourself spontaneously, precisely, and fluently. Equivalent to an educated native speaker.',
    'Complete mastery - educated native speaker level',
    'C2', 23000, NULL,
    '#FDCB6E', '#FDDB96', '#FCBA30',
    'crown',
    '👑 MASTER ACHIEVED! You have reached the pinnacle of English proficiency! You are now equivalent to an educated native speaker!',
    120,
    ARRAY['all_features', 'master_badge', 'exclusive_content', 'community_mentor', 'certification'],
    ARRAY['all_topics', 'specialized_professional', 'academic_excellence', 'cultural_mastery', 'native_literature'],
    ARRAY['complete_grammar_mastery', 'stylistic_excellence', 'pragmatic_mastery', 'sociolinguistics', 'linguistic_analysis'],
    ARRAY['complete_mastery'],
    85, 10
);

COMMIT;
