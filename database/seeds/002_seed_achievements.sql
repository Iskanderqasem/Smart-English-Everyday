-- Seed: 002_seed_achievements.sql
-- Description: Achievement badges for gamification
-- Created: 2024-01-01

BEGIN;

INSERT INTO achievements (
    name, slug, title, description, long_description,
    category, rarity, icon_name, badge_url,
    color_hex, trigger_type, trigger_value,
    xp_reward, gems_reward, title_reward,
    is_progressive, progress_milestones,
    sort_order
) VALUES

-- ===== STREAK ACHIEVEMENTS =====
(
    'first_streak', 'first-streak', '🔥 First Flame', 'Complete lessons 3 days in a row',
    'You''ve shown real commitment! Three consecutive days of learning sets the foundation for a lasting habit. Keep the flame burning!',
    'streak', 'common', 'flame', '/badges/first_flame.png', '#FF6B35',
    'streak_days', 3, 25, 5, NULL, FALSE, '{}', 10
),
(
    'week_warrior', 'week-warrior', '⚡ Week Warrior', 'Maintain a 7-day streak',
    'A full week of daily learning! You''ve proven that consistency is your superpower. Most learners never reach this milestone.',
    'streak', 'common', 'lightning', '/badges/week_warrior.png', '#FFC107',
    'streak_days', 7, 50, 10, 'Week Warrior', FALSE, '{}', 11
),
(
    'fortnight_fighter', 'fortnight-fighter', '🛡️ Fortnight Fighter', 'Maintain a 14-day streak',
    'Two weeks straight! Your dedication is truly impressive. You''re building a powerful learning habit.',
    'streak', 'uncommon', 'shield', '/badges/fortnight_fighter.png', '#4CAF50',
    'streak_days', 14, 100, 20, NULL, FALSE, '{}', 12
),
(
    'month_master', 'month-master', '🌟 Month Master', 'Maintain a 30-day streak',
    'An entire month without missing a single day! This level of commitment puts you in the top 5% of learners worldwide.',
    'streak', 'rare', 'star_four', '/badges/month_master.png', '#9C27B0',
    'streak_days', 30, 200, 50, 'Month Master', FALSE, '{}', 13
),
(
    'streak_50', 'streak-50', '💎 Golden Streak', '50-day learning streak',
    'Fifty consecutive days of learning! You have achieved what most only dream of. Your consistency is extraordinary.',
    'streak', 'epic', 'diamond', '/badges/golden_streak.png', '#FF9800',
    'streak_days', 50, 300, 75, NULL, FALSE, '{}', 14
),
(
    'century_streak', 'century-streak', '👑 Century Champion', '100-day learning streak',
    'ONE HUNDRED DAYS! You are in a league of your own. This achievement marks you as a truly exceptional learner.',
    'streak', 'legendary', 'crown', '/badges/century_champion.png', '#FFD700',
    'streak_days', 100, 500, 100, 'Century Champion', FALSE, '{}', 15
),
(
    'year_long', 'year-long', '🌈 Year-Round Learner', 'Complete a 365-day streak',
    'Every single day for an entire year! This is a feat achieved by less than 0.1% of learners. You are a true inspiration.',
    'streak', 'legendary', 'rainbow', '/badges/year_round.png', '#E91E63',
    'streak_days', 365, 1000, 200, 'English Legend', FALSE, '{}', 16
),

-- ===== LESSON ACHIEVEMENTS =====
(
    'first_lesson', 'first-lesson', '🎯 First Step', 'Complete your first lesson',
    'Every expert was once a beginner. Completing your first lesson is the most important step on your English journey!',
    'lesson', 'common', 'target', '/badges/first_step.png', '#2196F3',
    'lessons_completed', 1, 10, 2, NULL, FALSE, '{}', 20
),
(
    'five_lessons', 'five-lessons', '📚 Bookworm', 'Complete 5 lessons',
    'You''re building momentum! Five lessons down and the world of English is opening up to you.',
    'lesson', 'common', 'book', '/badges/bookworm.png', '#607D8B',
    'lessons_completed', 5, 25, 5, NULL, TRUE, '{1,3,5}', 21
),
(
    'lesson_10', 'lesson-10', '🏃 Lesson Runner', 'Complete 10 lessons',
    'Ten lessons completed! You''ve crossed the threshold where real learning begins.',
    'lesson', 'common', 'running', '/badges/lesson_runner.png', '#00BCD4',
    'lessons_completed', 10, 50, 10, NULL, TRUE, '{5,10}', 22
),
(
    'lesson_25', 'lesson-25', '📖 Story Teller', 'Complete 25 lessons',
    'A quarter-century of lessons! Your English vocabulary and grammar are growing rapidly.',
    'lesson', 'uncommon', 'story', '/badges/story_teller.png', '#8BC34A',
    'lessons_completed', 25, 75, 15, NULL, TRUE, '{10,25}', 23
),
(
    'lesson_50', 'lesson-50', '🎓 Scholar', 'Complete 50 lessons',
    'Fifty lessons of dedicated learning! You''ve earned the title of Scholar. Your commitment is admirable.',
    'lesson', 'uncommon', 'graduation', '/badges/scholar.png', '#FF5722',
    'lessons_completed', 50, 100, 25, 'Scholar', TRUE, '{10,25,50}', 24
),
(
    'lesson_100', 'lesson-100', '🏆 Century Learner', 'Complete 100 lessons',
    'One hundred lessons! You have climbed a mountain. Your dedication to learning English is truly remarkable.',
    'lesson', 'rare', 'trophy', '/badges/century_learner.png', '#FFC107',
    'lessons_completed', 100, 200, 50, NULL, TRUE, '{25,50,75,100}', 25
),
(
    'lesson_250', 'lesson-250', '🌠 Shooting Star', 'Complete 250 lessons',
    'Two hundred and fifty lessons! You''re in the elite tier of learners. Your English must be outstanding by now.',
    'lesson', 'epic', 'shooting_star', '/badges/shooting_star.png', '#9C27B0',
    'lessons_completed', 250, 500, 100, 'Star Student', TRUE, '{50,100,200,250}', 26
),
(
    'lesson_500', 'lesson-500', '👑 Grand Master', 'Complete 500 lessons',
    'FIVE HUNDRED LESSONS! You are a true Grand Master of English learning. This places you among the most dedicated learners on earth.',
    'lesson', 'legendary', 'crown_grand', '/badges/grand_master.png', '#FFD700',
    'lessons_completed', 500, 1000, 200, 'Grand Master', TRUE, '{100,200,350,500}', 27
),

-- ===== PERFECT LESSON ACHIEVEMENTS =====
(
    'first_perfect', 'first-perfect', '⭐ Perfectionist', 'Complete a lesson with 100% accuracy',
    'Perfect score! Not a single mistake. This is the mark of a careful and focused learner.',
    'accuracy', 'common', 'star', '/badges/perfectionist.png', '#FFEB3B',
    'perfect_lessons', 1, 30, 8, NULL, FALSE, '{}', 30
),
(
    'perfect_5', 'perfect-5', '🌟 Star Performer', 'Achieve perfect scores in 5 lessons',
    'Five perfect lessons! Consistency in excellence is the hallmark of a true high achiever.',
    'accuracy', 'uncommon', 'stars', '/badges/star_performer.png', '#FF9800',
    'perfect_lessons', 5, 75, 20, NULL, TRUE, '{1,3,5}', 31
),
(
    'perfect_20', 'perfect-20', '💫 Flawless', 'Achieve perfect scores in 20 lessons',
    'Twenty perfect lessons! Your precision and attention to detail are extraordinary.',
    'accuracy', 'rare', 'sparkles', '/badges/flawless.png', '#E91E63',
    'perfect_lessons', 20, 150, 40, 'Perfectionist', TRUE, '{5,10,20}', 32
),

-- ===== VOCABULARY ACHIEVEMENTS =====
(
    'vocab_10', 'vocab-10', '🔤 Word Collector', 'Learn 10 new words',
    'Ten new English words are now part of your vocabulary. Every word learned is a new tool for communication!',
    'vocabulary', 'common', 'alphabet', '/badges/word_collector.png', '#4CAF50',
    'words_learned', 10, 15, 3, NULL, TRUE, '{5,10}', 40
),
(
    'vocab_50', 'vocab-50', '📝 Vocabulary Builder', 'Learn 50 words',
    'Fifty words mastered! You can now express yourself across a wide range of topics.',
    'vocabulary', 'common', 'pencil', '/badges/vocabulary_builder.png', '#2196F3',
    'words_learned', 50, 40, 8, NULL, TRUE, '{10,25,50}', 41
),
(
    'vocab_100', 'vocab-100', '📚 Word Hoarder', 'Learn 100 words',
    'One hundred words in your arsenal! A vocabulary of 100 words covers most basic conversations.',
    'vocabulary', 'uncommon', 'books', '/badges/word_hoarder.png', '#9C27B0',
    'words_learned', 100, 75, 15, NULL, TRUE, '{25,50,100}', 42
),
(
    'vocab_500', 'vocab-500', '🧠 Lexicon Master', 'Learn 500 words',
    'Five hundred words! Research shows that knowing 500 words allows understanding of 80% of everyday conversation.',
    'vocabulary', 'rare', 'brain', '/badges/lexicon_master.png', '#FF5722',
    'words_learned', 500, 200, 50, 'Word Wizard', TRUE, '{100,200,350,500}', 43
),
(
    'vocab_1000', 'vocab-1000', '🌍 Fluency Threshold', 'Learn 1,000 words',
    'ONE THOUSAND WORDS! You''ve crossed the fluency threshold. Research shows 1,000 words covers 90% of everyday English.',
    'vocabulary', 'epic', 'globe', '/badges/fluency_threshold.png', '#3F51B5',
    'words_learned', 1000, 400, 100, 'Vocabulary Elite', TRUE, '{250,500,750,1000}', 44
),
(
    'vocab_3000', 'vocab-3000', '👑 Oxford Standard', 'Learn 3,000 words',
    'THREE THOUSAND WORDS! This is the Oxford Standard for everyday fluency. You understand 95%+ of everyday English.',
    'vocabulary', 'legendary', 'crown_vocab', '/badges/oxford_standard.png', '#FFD700',
    'words_learned', 3000, 1000, 200, 'Oxford Graduate', TRUE, '{1000,2000,3000}', 45
),

-- ===== GRAMMAR ACHIEVEMENTS =====
(
    'grammar_basics', 'grammar-basics', '📐 Grammar Basics', 'Master basic grammar concepts',
    'You''ve got the grammar basics down! Understanding fundamental grammar rules is the foundation of clear communication.',
    'grammar', 'common', 'ruler', '/badges/grammar_basics.png', '#607D8B',
    'assessments_passed', 1, 30, 5, NULL, FALSE, '{}', 50
),
(
    'grammar_master', 'grammar-master', '⚙️ Grammar Master', 'Complete all grammar lessons',
    'Grammar Master! You understand the rules that make English work. Your writing and speaking will be noticeably more precise.',
    'grammar', 'epic', 'gear', '/badges/grammar_master.png', '#FF9800',
    'lessons_completed', 50, 300, 75, 'Grammar Master', FALSE, '{}', 51
),

-- ===== LEVEL ACHIEVEMENTS =====
(
    'level_2', 'level-2', '🌱 Growing', 'Reach Level 2',
    'You''ve grown beyond the very basics! Level 2 means you can handle simple everyday expressions.',
    'level', 'common', 'sprout', '/badges/level_2.png', '#4CAF50',
    'level_reached', 2, 25, 5, NULL, FALSE, '{}', 60
),
(
    'level_5', 'level-5', '🌿 Intermediate Explorer', 'Reach Level 5 (B1)',
    'Level 5 - B1 achieved! You''ve reached the international standard for basic communication. Incredible!',
    'level', 'rare', 'plant', '/badges/level_5_b1.png', '#00BCD4',
    'level_reached', 5, 150, 35, 'B1 Achiever', FALSE, '{}', 65
),
(
    'level_7', 'level-7', '🌳 B2 Champion', 'Reach Level 7 (B2)',
    'Level 7 - B2 achieved! You can now interact fluently with native speakers and study at international universities.',
    'level', 'epic', 'tree', '/badges/level_7_b2.png', '#3F51B5',
    'level_reached', 7, 300, 75, 'B2 Champion', FALSE, '{}', 67
),
(
    'level_10', 'level-10', '👑 English Master', 'Reach the maximum Level 10 (C2)',
    'LEVEL 10 - C2 MASTERY! You have achieved the highest possible level. You communicate at the level of an educated native speaker. You are an English Master.',
    'level', 'legendary', 'crown_level', '/badges/level_10_c2.png', '#FFD700',
    'level_reached', 10, 1000, 250, 'English Master', FALSE, '{}', 70
),

-- ===== XP MILESTONES =====
(
    'xp_1000', 'xp-1000', '⚡ Power Starter', 'Earn 1,000 XP',
    'One thousand experience points! You''re powering through your English journey.',
    'milestone', 'common', 'bolt', '/badges/power_starter.png', '#FFEB3B',
    'xp_total', 1000, 20, 4, NULL, TRUE, '{250,500,1000}', 80
),
(
    'xp_5000', 'xp-5000', '🔋 Energy Core', 'Earn 5,000 XP',
    'Five thousand XP! Your learning energy is boundless. You''re in the top learner category.',
    'milestone', 'uncommon', 'battery', '/badges/energy_core.png', '#4CAF50',
    'xp_total', 5000, 75, 15, NULL, TRUE, '{1000,2500,5000}', 81
),
(
    'xp_10000', 'xp-10000', '💥 Power House', 'Earn 10,000 XP',
    'TEN THOUSAND XP! You are a powerhouse learner. Your dedication is extraordinary.',
    'milestone', 'rare', 'explosion', '/badges/power_house.png', '#FF5722',
    'xp_total', 10000, 150, 30, 'XP Elite', TRUE, '{2500,5000,7500,10000}', 82
),
(
    'xp_50000', 'xp-50000', '🌋 Unstoppable', 'Earn 50,000 XP',
    'FIFTY THOUSAND XP! You are absolutely unstoppable. This level of dedication is legendary.',
    'milestone', 'legendary', 'volcano', '/badges/unstoppable.png', '#9C27B0',
    'xp_total', 50000, 500, 100, 'XP Legend', TRUE, '{10000,25000,50000}', 83
),

-- ===== CONSISTENCY ACHIEVEMENTS =====
(
    'early_bird', 'early-bird', '🌅 Early Bird', 'Complete 7 lessons before 8 AM',
    'Early bird catches the word! You prove that mornings are the best time for learning.',
    'consistency', 'uncommon', 'sunrise', '/badges/early_bird.png', '#FF9800',
    'days_active', 7, 60, 12, 'Early Bird', FALSE, '{}', 90
),
(
    'night_owl', 'night-owl', '🦉 Night Owl', 'Complete 7 lessons after 10 PM',
    'The night is your classroom! While others sleep, you learn. Dedication knows no schedule.',
    'consistency', 'uncommon', 'owl', '/badges/night_owl.png', '#3F51B5',
    'days_active', 7, 60, 12, 'Night Owl', FALSE, '{}', 91
),
(
    'weekend_warrior', 'weekend-warrior', '🏖️ Weekend Warrior', 'Study on 10 weekends',
    'Weekends are for learning too! You''re committed to improvement even when others relax.',
    'consistency', 'rare', 'beach', '/badges/weekend_warrior.png', '#00BCD4',
    'days_active', 20, 100, 20, NULL, TRUE, '{2,5,10}', 92
),

-- ===== SPEAKING ACHIEVEMENTS =====
(
    'first_speech', 'first-speech', '🎤 First Words', 'Complete your first speaking exercise',
    'You spoke English for the first time! Every great speaker started exactly where you are now.',
    'speaking', 'common', 'mic', '/badges/first_words.png', '#E91E63',
    'minutes_studied', 5, 20, 4, NULL, FALSE, '{}', 100
),
(
    'pronunciation_pro', 'pronunciation-pro', '🗣️ Pronunciation Pro', 'Score 90%+ on 10 pronunciation exercises',
    'Your pronunciation is impressive! Native speakers will understand you clearly. That''s a huge achievement.',
    'speaking', 'rare', 'speaking', '/badges/pronunciation_pro.png', '#FF5722',
    'accuracy_percent', 90, 100, 25, 'Pronunciation Pro', FALSE, '{}', 101
),

-- ===== SOCIAL / REFERRAL =====
(
    'first_referral', 'first-referral', '🤝 Team Builder', 'Refer your first friend',
    'Sharing is caring! You''ve brought a friend on this English learning journey. Together you''ll go further.',
    'social', 'common', 'handshake', '/badges/team_builder.png', '#4CAF50',
    'referrals', 1, 50, 10, NULL, FALSE, '{}', 110
),
(
    'referral_5', 'referral-5', '🌐 Community Builder', 'Refer 5 friends',
    'Five friends learning English because of you! You''re building a community of English learners.',
    'social', 'rare', 'network', '/badges/community_builder.png', '#2196F3',
    'referrals', 5, 150, 30, 'Community Builder', TRUE, '{1,3,5}', 111
),

-- ===== SPECIAL / SEASONAL =====
(
    'founder', 'founder', '🏛️ Founding Member', 'Be among the first 1000 users',
    'You are one of the founding members of Smart English Everyday! Your early support helped build this platform.',
    'special', 'legendary', 'pillar', '/badges/founder.png', '#FFD700',
    'special_event', 1000, 250, 50, 'Founding Member', FALSE, '{}', 200
),
(
    'beta_tester', 'beta-tester', '🧪 Beta Pioneer', 'Test the app during beta phase',
    'You helped shape Smart English Everyday during its beta phase. Your feedback made the app better for everyone!',
    'special', 'epic', 'flask', '/badges/beta_pioneer.png', '#9C27B0',
    'special_event', 1, 100, 20, 'Beta Pioneer', FALSE, '{}', 201
);

COMMIT;
