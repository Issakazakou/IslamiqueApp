-- ============================================================================
-- Quiz Islamique : toutes les questions (Coran, Hadith, Fiqh, Sira)   SQL Server / T-SQL
-- questions (1 ligne par question) + choix (1 ligne par choix, 4 par question).
-- est_correct = 1 pour le bon choix. L'ordre des choix = ordre de choix.id (insertion).
-- Le backend PHP lit ces tables quand QUIZ_DB_DSN est défini (voir backend/README.md).
-- ============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;   -- en cas d'erreur, tout est annulé

IF OBJECT_ID(N'dbo.questions', N'U') IS NULL
    CREATE TABLE dbo.questions (
        id         INT           NOT NULL PRIMARY KEY,
        categorie  NVARCHAR(20)  NOT NULL,                                   -- coran_culture, hadith, fiqh, sira, coran_mediter, coran_tajwid
        niveau     NVARCHAR(20)  NOT NULL
                   CONSTRAINT CK_questions_niveau CHECK (niveau IN (N'debutant', N'intermediaire', N'avance')),
        enonce     NVARCHAR(255) NOT NULL
    );
GO

IF OBJECT_ID(N'dbo.choix', N'U') IS NULL
    CREATE TABLE dbo.choix (
        id          INT IDENTITY(1,1) PRIMARY KEY,
        question_id INT           NOT NULL
                    CONSTRAINT FK_choix_questions REFERENCES dbo.questions(id),
        choix       NVARCHAR(255) NOT NULL,
        est_correct BIT           NOT NULL CONSTRAINT DF_choix_est_correct DEFAULT 0
    );
GO

-- Une seule bonne réponse par question (garde-fou)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_choix_une_bonne_par_question' AND object_id = OBJECT_ID(N'dbo.choix'))
    CREATE UNIQUE INDEX UX_choix_une_bonne_par_question ON dbo.choix (question_id) WHERE est_correct = 1;
GO

BEGIN TRANSACTION;

-- ======== CORAN – CULTURE CORANIQUE : 75 questions ========

INSERT INTO dbo.questions (id, categorie, niveau, enonce) VALUES
    (1, N'coran_culture', N'debutant', N'Combien de sourates contient le Coran ?'),
    (2, N'coran_culture', N'debutant', N'Quelle est la première sourate du Coran selon l''ordre du Mushaf ?'),
    (3, N'coran_culture', N'debutant', N'Quelle est la plus longue sourate du Coran ?'),
    (4, N'coran_culture', N'debutant', N'Quelle est la plus courte sourate du Coran ?'),
    (5, N'coran_culture', N'debutant', N'Quelle sourate ne commence pas par la Basmala ?'),
    (6, N'coran_culture', N'debutant', N'Quelle sourate contient deux Basmala ?'),
    (7, N'coran_culture', N'debutant', N'Quel est le plus long verset du Coran ?'),
    (8, N'coran_culture', N'debutant', N'Dans quelle sourate se trouve Ayat al-Kursi (le verset du Trône) ?'),
    (9, N'coran_culture', N'debutant', N'Combien de Juz'' (parties) compte le Coran ?'),
    (10, N'coran_culture', N'debutant', N'Combien de Hizb compte le Coran ?'),
    (11, N'coran_culture', N'debutant', N'Quelle sourate est surnommée ''Umm al-Kitab'' (la Mère du Livre) ?'),
    (12, N'coran_culture', N'debutant', N'Quelle sourate équivaut au tiers du Coran selon les enseignements du Prophète ﷺ ?'),
    (13, N'coran_culture', N'debutant', N'Quelles sont les deux sourates protectrices dites ''Al-Mu''awwidhatayn'' ?'),
    (14, N'coran_culture', N'debutant', N'Dans quelle sourate est racontée l''histoire détaillée du prophète Youssef (Joseph) ?'),
    (15, N'coran_culture', N'debutant', N'Quel prophète est le plus fréquemment mentionné par son nom dans le Coran ?'),
    (16, N'coran_culture', N'debutant', N'Quelle est la seule femme mentionnée nommément dans le Coran ?'),
    (17, N'coran_culture', N'debutant', N'Dans quelle sourate se trouve l''histoire des Gens de la Caverne (Ahl al-Kahf) ?'),
    (18, N'coran_culture', N'debutant', N'Quel prophète a construit la Ka''ba avec son fils Isma''il ?'),
    (19, N'coran_culture', N'debutant', N'Quelle sourate porte le nom d''un fruit cité dans le Coran ?'),
    (20, N'coran_culture', N'debutant', N'Quel événement est commémoré par la nuit de Laylat al-Qadr ?'),
    (21, N'coran_culture', N'debutant', N'Combien d''années la révélation du Coran a-t-elle duré environ ?'),
    (22, N'coran_culture', N'debutant', N'Dans quelle ville les sourates ''médinoises'' ont-elles été révélées ?'),
    (23, N'coran_culture', N'debutant', N'Dans quelle ville les sourates ''mecquoises'' ont-elles été révélées ?'),
    (24, N'coran_culture', N'debutant', N'Quel compagnon est le seul cité nommément dans le Coran ?'),
    (25, N'coran_culture', N'debutant', N'Quelle sourate est surnommée le ''Cœur du Coran'' ?'),
    (26, N'coran_culture', N'intermediaire', N'Quelle sourate évoque le voyage nocturne du Prophète ﷺ (Al-Isra) ?'),
    (27, N'coran_culture', N'intermediaire', N'Quel prophète a parlé au berceau selon le Coran ?'),
    (28, N'coran_culture', N'intermediaire', N'Quel peuple a été sauvé par la mer fendue par miracle ?'),
    (29, N'coran_culture', N'intermediaire', N'Quel prophète a été avalé par un grand poisson ?'),
    (30, N'coran_culture', N'intermediaire', N'Quel prophète est célèbre pour sa grande patience face à l''épreuve ?'),
    (31, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Aal ''Imran dans le Coran ?'),
    (32, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate An-Nisa dans le Coran ?'),
    (33, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-Ma''idah dans le Coran ?'),
    (34, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-An''am dans le Coran ?'),
    (35, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-A''raf dans le Coran ?'),
    (36, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-Anfal dans le Coran ?'),
    (37, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Younus dans le Coran ?'),
    (38, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Houd dans le Coran ?'),
    (39, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Youssef dans le Coran ?'),
    (40, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Ar-Ra''d dans le Coran ?'),
    (41, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Ibrahim dans le Coran ?'),
    (42, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-Hijr dans le Coran ?'),
    (43, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate An-Nahl dans le Coran ?'),
    (44, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-Isra dans le Coran ?'),
    (45, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-Kahf dans le Coran ?'),
    (46, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Maryam dans le Coran ?'),
    (47, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Taha dans le Coran ?'),
    (48, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-Anbiya dans le Coran ?'),
    (49, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-Hajj dans le Coran ?'),
    (50, N'coran_culture', N'intermediaire', N'Quel est le numéro d''ordre de la sourate Al-Mu''minun dans le Coran ?'),
    (51, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate An-Nur dans le Coran ?'),
    (52, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Al-Furqan dans le Coran ?'),
    (53, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Ash-Shu''ara dans le Coran ?'),
    (54, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate An-Naml dans le Coran ?'),
    (55, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Al-Qasas dans le Coran ?'),
    (56, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Al-''Ankabut dans le Coran ?'),
    (57, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Ar-Rum dans le Coran ?'),
    (58, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Luqman dans le Coran ?'),
    (59, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate As-Sajdah dans le Coran ?'),
    (60, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Al-Ahzab dans le Coran ?'),
    (61, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Saba dans le Coran ?'),
    (62, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Fatir dans le Coran ?'),
    (63, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Yasin dans le Coran ?'),
    (64, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate As-Saffat dans le Coran ?'),
    (65, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Sad dans le Coran ?'),
    (66, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Az-Zumar dans le Coran ?'),
    (67, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Ghafir dans le Coran ?'),
    (68, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Fussilat dans le Coran ?'),
    (69, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Ash-Shura dans le Coran ?'),
    (70, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Az-Zukhruf dans le Coran ?'),
    (71, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Ad-Dukhan dans le Coran ?'),
    (72, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Al-Jathiyah dans le Coran ?'),
    (73, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Al-Ahqaf dans le Coran ?'),
    (74, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Muhammad dans le Coran ?'),
    (75, N'coran_culture', N'avance', N'Quel est le numéro d''ordre de la sourate Al-Fath dans le Coran ?');

-- ======== HADITH : 75 questions ========

INSERT INTO dbo.questions (id, categorie, niveau, enonce) VALUES
    (76, N'hadith', N'debutant', N'Selon le célèbre hadith, « Les actions ne valent que par... »'),
    (77, N'hadith', N'debutant', N'Quel imam est l''auteur du recueil de hadiths considéré comme le plus authentique ?'),
    (78, N'hadith', N'debutant', N'Quel recueil est considéré comme le plus authentique juste après Sahih Al-Bukhari ?'),
    (79, N'hadith', N'debutant', N'Comment appelle-t-on l''ensemble des deux recueils Sahih Al-Bukhari et Sahih Muslim ?'),
    (80, N'hadith', N'debutant', N'Que signifie le terme ''Hadith Qudsi'' ?'),
    (81, N'hadith', N'debutant', N'Quel compagnon a rapporté le plus grand nombre de hadiths du Prophète ﷺ ?'),
    (82, N'hadith', N'debutant', N'Quel compagnon, serviteur du Prophète ﷺ pendant dix ans à Médine, a rapporté de très nombreux hadiths ?'),
    (83, N'hadith', N'debutant', N'Quelle épouse du Prophète ﷺ a rapporté un très grand nombre de hadiths ?'),
    (84, N'hadith', N'debutant', N'Dans le hadith de Jibril (Gabriel), quels sont les trois niveaux de la religion enseignés ?'),
    (85, N'hadith', N'debutant', N'Que signifie ''Ihsan'' selon le hadith de Jibril ?'),
    (86, N'hadith', N'debutant', N'Combien de piliers compte l''Islam selon le hadith d''Ibn Omar ?'),
    (87, N'hadith', N'debutant', N'Combien de piliers compte la foi (Iman) selon le hadith de Jibril ?'),
    (88, N'hadith', N'debutant', N'Selon le hadith : « Le meilleur d''entre vous est celui qui apprend... »'),
    (89, N'hadith', N'debutant', N'Selon le hadith : « Aucun d''entre vous ne croit vraiment jusqu''à ce qu''il aime pour son frère... »'),
    (90, N'hadith', N'debutant', N'Selon le hadith : « La recherche de la science est... »'),
    (91, N'hadith', N'debutant', N'Selon le hadith : « La purification est... »'),
    (92, N'hadith', N'debutant', N'Quel jeune compagnon était surnommé ''Al-Hibb'' (le bien-aimé du Prophète ﷺ) ?'),
    (93, N'hadith', N'debutant', N'Selon le hadith : « Dis la vérité, même si elle est... »'),
    (94, N'hadith', N'debutant', N'Quel savant a rédigé le célèbre recueil des ''Quarante Hadiths'' (Al-Arba''in) ?'),
    (95, N'hadith', N'debutant', N'Selon le hadith, que doit faire celui qui voit un acte blâmable ?'),
    (96, N'hadith', N'debutant', N'Comment appelle-t-on la chaîne de transmission d''un hadith ?'),
    (97, N'hadith', N'debutant', N'Comment appelle-t-on le texte même du hadith ?'),
    (98, N'hadith', N'debutant', N'Comment qualifie-t-on un hadith authentique, à la chaîne ininterrompue et aux narrateurs fiables ?'),
    (99, N'hadith', N'debutant', N'Comment qualifie-t-on un hadith inventé ou fabriqué ?'),
    (100, N'hadith', N'debutant', N'Quel ouvrage de hadith et de fiqh a été rédigé par l''Imam Malik ibn Anas ?'),
    (101, N'hadith', N'intermediaire', N'Selon le hadith : « Le fort n''est pas celui qui terrasse les gens, mais celui qui... »'),
    (102, N'hadith', N'intermediaire', N'Quel conseil bref le Prophète ﷺ a-t-il répété à un homme qui lui demandait un conseil ?'),
    (103, N'hadith', N'intermediaire', N'Selon le hadith, comment doit-on traiter son voisin ?'),
    (104, N'hadith', N'intermediaire', N'Selon le hadith : « Sourire à ton frère est une... »'),
    (105, N'hadith', N'intermediaire', N'Selon le hadith, la meilleure des aumônes est celle faite tout en étant...'),
    (106, N'hadith', N'intermediaire', N'Quel savant est l''auteur du célèbre recueil ''Riyad as-Salihin'' ?'),
    (107, N'hadith', N'intermediaire', N'Qui est l''auteur de ''Fath al-Bari'', le grand commentaire de Sahih Al-Bukhari ?'),
    (108, N'hadith', N'intermediaire', N'Quel est le nom complet de l''Imam Al-Bukhari ?'),
    (109, N'hadith', N'intermediaire', N'Quel est le nom complet de l''auteur de Sahih Muslim ?'),
    (110, N'hadith', N'intermediaire', N'Quel imam est l''auteur du célèbre ''Musnad'' ?'),
    (111, N'hadith', N'intermediaire', N'Que désigne l''expression ''Kutub as-Sittah'' ?'),
    (112, N'hadith', N'intermediaire', N'Comment appelle-t-on un hadith rapporté par un si grand nombre de narrateurs que leur entente sur un mensonge est impossible ?'),
    (113, N'hadith', N'intermediaire', N'Comment appelle-t-on un hadith dont la chaîne présente un défaut, comme un narrateur peu fiable ?'),
    (114, N'hadith', N'intermediaire', N'Comment appelle-t-on un hadith acceptable, dont la fiabilité est légèrement inférieure à celle du Sahih ?'),
    (115, N'hadith', N'intermediaire', N'Comment appelle-t-on un hadith rapporté par un seul narrateur à un niveau de la chaîne ?'),
    (116, N'hadith', N'intermediaire', N'Comment appelle-t-on un narrateur de hadith ?'),
    (117, N'hadith', N'intermediaire', N'Comment appelle-t-on un savant spécialiste des hadiths ?'),
    (118, N'hadith', N'intermediaire', N'Quel est le premier pilier cité dans le hadith de Jibril ?'),
    (119, N'hadith', N'intermediaire', N'Selon le hadith : « Que celui qui croit en Allah et au Jour dernier dise du bien ou qu''il... »'),
    (120, N'hadith', N'intermediaire', N'Selon le hadith : « Facilitez et ne rendez pas les choses... »'),
    (121, N'hadith', N'intermediaire', N'Selon le hadith : « La religion, c''est... »'),
    (122, N'hadith', N'intermediaire', N'Selon le hadith : « Ne vous enviez pas, ne vous détestez pas... et soyez, ô serviteurs d''Allah, des... »'),
    (123, N'hadith', N'intermediaire', N'Selon le hadith, quelle est l''œuvre la plus aimée d''Allah ?'),
    (124, N'hadith', N'intermediaire', N'Selon le hadith, qui a le plus de droit à ta bonne compagnie ?'),
    (125, N'hadith', N'intermediaire', N'Selon le hadith, la pudeur (Al-Haya'') fait partie de...'),
    (126, N'hadith', N'avance', N'Dans le hadith sur les branches de la foi, quelle est la plus haute ?'),
    (127, N'hadith', N'avance', N'Que répond-on à celui qui éternue et dit « Al-hamdulillah » ?'),
    (128, N'hadith', N'avance', N'Que dit-on avant de manger selon la Sunnah ?'),
    (129, N'hadith', N'avance', N'Avec quelle main le Prophète ﷺ a-t-il recommandé de manger ?'),
    (130, N'hadith', N'avance', N'Selon le hadith, que se passe-t-il pour celui qui invoque la paix sur le Prophète ﷺ une fois ?'),
    (131, N'hadith', N'avance', N'Selon le hadith, quel est le meilleur jour de la semaine ?'),
    (132, N'hadith', N'avance', N'Quels sont les deux jours de jeûne surérogatoire hebdomadaire recommandés par le Prophète ﷺ ?'),
    (133, N'hadith', N'avance', N'Quel compagnon a rapporté le hadith des intentions ?'),
    (134, N'hadith', N'avance', N'Quel compagnon, grand rapporteur de hadiths, est surnommé « le père du chaton » ?'),
    (135, N'hadith', N'avance', N'Quel compagnon, cousin du Prophète ﷺ, est surnommé « l''interprète du Coran » ?'),
    (136, N'hadith', N'avance', N'Combien de hadiths contient réellement le recueil des « Quarante Hadiths » de l''Imam An-Nawawi ?'),
    (137, N'hadith', N'avance', N'Que désigne la ''Sunnah'' au sens large ?'),
    (138, N'hadith', N'avance', N'Comment appelle-t-on l''approbation tacite du Prophète ﷺ à un acte accompli devant lui ?'),
    (139, N'hadith', N'avance', N'Selon le hadith, quelle est la meilleure formule de dhikr ?'),
    (140, N'hadith', N'avance', N'Quelles paroles sont « légères sur la langue, lourdes dans la balance, aimées du Miséricordieux » ?'),
    (141, N'hadith', N'avance', N'Selon le hadith, qui doit saluer en premier ?'),
    (142, N'hadith', N'avance', N'Selon le hadith, le musulman est celui dont les musulmans sont à l''abri de sa langue et de sa...'),
    (143, N'hadith', N'avance', N'Selon le hadith du ''failli'' (Al-Muflis), qui est le véritable failli le Jour du Jugement ?'),
    (144, N'hadith', N'avance', N'Selon le hadith, qui est plus aimé d''Allah ?'),
    (145, N'hadith', N'avance', N'Selon le hadith, celui qui emprunte un chemin pour chercher la science, Allah lui facilite...'),
    (146, N'hadith', N'avance', N'À la mort de l''homme, ses œuvres s''arrêtent sauf : une aumône continue, une science utile et...'),
    (147, N'hadith', N'avance', N'Selon le hadith, qu''est-ce que la médisance (Al-Ghiba) ?'),
    (148, N'hadith', N'avance', N'Selon le hadith, que dit-on à celui qui nous a fait un bien pour bien le remercier ?'),
    (149, N'hadith', N'avance', N'Parmi les sept personnes à l''ombre d''Allah au Jour du Jugement, on trouve...'),
    (150, N'hadith', N'avance', N'Selon le hadith, que fait Allah pour celui qui cache la faute d''un musulman ?');

-- ======== FIQH : 75 questions ========

INSERT INTO dbo.questions (id, categorie, niveau, enonce) VALUES
    (151, N'fiqh', N'debutant', N'Combien de prières obligatoires (Fard) un musulman doit-il accomplir par jour ?'),
    (152, N'fiqh', N'debutant', N'Quel est le premier pilier pratique de l''Islam après la double attestation de foi (Shahada) ?'),
    (153, N'fiqh', N'debutant', N'Quelle est la condition préalable de purification avant d''accomplir la prière ?'),
    (154, N'fiqh', N'debutant', N'Comment s''appelle l''ablution sèche réalisée avec de la terre propre en l''absence d''eau ?'),
    (155, N'fiqh', N'debutant', N'Comment s''appelle le lavage purificateur de tout le corps ?'),
    (156, N'fiqh', N'debutant', N'Quelle prière obligatoire est accomplie entre l''aube et le lever du soleil ?'),
    (157, N'fiqh', N'debutant', N'Combien de Raka''at compte la prière du Dhuhr ?'),
    (158, N'fiqh', N'debutant', N'Combien de Raka''at compte la prière du Maghrib ?'),
    (159, N'fiqh', N'debutant', N'Combien de Raka''at compte la prière de l''Isha ?'),
    (160, N'fiqh', N'debutant', N'Quelle prière collective remplace le Dhuhr le vendredi ?'),
    (161, N'fiqh', N'debutant', N'Vers quelle direction (Qibla) les musulmans se tournent-ils pour prier ?'),
    (162, N'fiqh', N'debutant', N'Comment s''appelle l''appel à la prière lancé par le muezzin ?'),
    (163, N'fiqh', N'debutant', N'Comment s''appelle le second appel annonçant le début imminent de la prière en groupe ?'),
    (164, N'fiqh', N'debutant', N'Durant quel mois du calendrier hégirien le jeûne est-il obligatoire ?'),
    (165, N'fiqh', N'debutant', N'De quand à quand s''étend le jeûne quotidien pendant Ramadan ?'),
    (166, N'fiqh', N'debutant', N'Comment s''appelle le repas pris avant l''aube avant de jeûner ?'),
    (167, N'fiqh', N'debutant', N'Comment s''appelle la rupture du jeûne au coucher du soleil ?'),
    (168, N'fiqh', N'debutant', N'Quel pilier de l''Islam consiste à verser une aumône purificatrice sur ses biens ?'),
    (169, N'fiqh', N'debutant', N'Quel est le taux standard de la Zakat sur l''argent épargné pendant un an ?'),
    (170, N'fiqh', N'debutant', N'Quel pilier de l''Islam est obligatoire une fois dans la vie pour qui en a les moyens ?'),
    (171, N'fiqh', N'debutant', N'Comment s''appelle le petit pèlerinage qui peut être accompli à n''importe quel moment de l''année ?'),
    (172, N'fiqh', N'debutant', N'Quel est le jour le plus important du grand pèlerinage (Hajj) ?'),
    (173, N'fiqh', N'debutant', N'Comment s''appelle l''état de sacralisation du pèlerin pour le Hajj ou la Umrah ?'),
    (174, N'fiqh', N'debutant', N'Comment s''appelle la circumambulation de sept tours autour de la Ka''ba ?'),
    (175, N'fiqh', N'debutant', N'Comment s''appelle la marche de sept trajets entre Safa et Marwa ?'),
    (176, N'fiqh', N'intermediaire', N'Combien d''écoles juridiques sunnites principales existent ?'),
    (177, N'fiqh', N'intermediaire', N'Quelles sont les 4 grandes écoles juridiques sunnites ?'),
    (178, N'fiqh', N'intermediaire', N'Que signifie ''Halal'' en Fiqh ?'),
    (179, N'fiqh', N'intermediaire', N'Que signifie ''Haram'' en Fiqh ?'),
    (180, N'fiqh', N'intermediaire', N'Que signifie le terme ''Fard'' ou ''Wajib'' ?'),
    (181, N'fiqh', N'intermediaire', N'Combien de Raka''at compte la prière de l''Asr ?'),
    (182, N'fiqh', N'intermediaire', N'Combien de Raka''at compte la prière du vendredi (Jumu''ah) ?'),
    (183, N'fiqh', N'intermediaire', N'Comment s''appelle la prière nocturne spéciale du mois de Ramadan ?'),
    (184, N'fiqh', N'intermediaire', N'Comment s''appelle la prière surérogatoire accomplie en milieu de matinée ?'),
    (185, N'fiqh', N'intermediaire', N'Comment s''appelle la prière pour demander la pluie ?'),
    (186, N'fiqh', N'intermediaire', N'Comment s''appelle la prière accomplie lors d''une éclipse solaire ?'),
    (187, N'fiqh', N'intermediaire', N'Comment s''appelle la prière accomplie pour un défunt ?'),
    (188, N'fiqh', N'intermediaire', N'Quel est le statut de la prière du Janazah pour la communauté ?'),
    (189, N'fiqh', N'intermediaire', N'Comment s''appelle le premier Takbir qui ouvre la prière ?'),
    (190, N'fiqh', N'intermediaire', N'Que dit-on lors de la prosternation (Sujud) ?'),
    (191, N'fiqh', N'intermediaire', N'Que dit-on lors de l''inclinaison (Ruku'') ?'),
    (192, N'fiqh', N'intermediaire', N'Combien de prosternations (Sujud) accomplit-on dans chaque Raka''ah ?'),
    (193, N'fiqh', N'intermediaire', N'Quelle sourate est récitée à chaque Raka''ah de la prière ?'),
    (194, N'fiqh', N'intermediaire', N'Lequel de ces éléments annule les ablutions ?'),
    (195, N'fiqh', N'intermediaire', N'Quelle partie du corps est essuyée (mas''h) et non lavée lors des ablutions ?'),
    (196, N'fiqh', N'intermediaire', N'Comment s''appelle l''essuyage sur les chaussettes de cuir lors des ablutions ?'),
    (197, N'fiqh', N'intermediaire', N'Quelle est la durée du mas''h sur les khuff pour le voyageur ?'),
    (198, N'fiqh', N'intermediaire', N'Quel est le nisab approximatif de l''or pour la Zakat ?'),
    (199, N'fiqh', N'intermediaire', N'Quand la Zakat al-Fitr doit-elle être versée ?'),
    (200, N'fiqh', N'intermediaire', N'Combien de catégories de bénéficiaires de la Zakat le Coran mentionne-t-il ?'),
    (201, N'fiqh', N'avance', N'Combien de jours dure le mois de Ramadan ?'),
    (202, N'fiqh', N'avance', N'Qu''est-ce qui invalide le jeûne ?'),
    (203, N'fiqh', N'avance', N'Durant quelle période de Ramadan recherche-t-on Laylat al-Qadr ?'),
    (204, N'fiqh', N'avance', N'Que désigne l''I''tikaf ?'),
    (205, N'fiqh', N'avance', N'À quelle date tombe l''Aïd al-Adha ?'),
    (206, N'fiqh', N'avance', N'Quel mois du calendrier hégirien suit Ramadan ?'),
    (207, N'fiqh', N'avance', N'Durant quel mois le Hajj a-t-il lieu ?'),
    (208, N'fiqh', N'avance', N'Comment s''appelle le rite de lapidation accompli à Mina ?'),
    (209, N'fiqh', N'avance', N'Où le pèlerin passe-t-il la nuit qui suit le jour d''Arafat ?'),
    (210, N'fiqh', N'avance', N'Comment s''appelle l''eau bénie du puits situé près de la Ka''ba ?'),
    (211, N'fiqh', N'avance', N'Comment s''appelle la dot versée par l''époux à l''épouse lors du mariage ?'),
    (212, N'fiqh', N'avance', N'Comment s''appelle le banquet de mariage ?'),
    (213, N'fiqh', N'avance', N'Comment s''appelle le sacrifice offert à la naissance d''un enfant ?'),
    (214, N'fiqh', N'avance', N'Comment s''appelle le sacrifice d''un animal lors de l''Aïd al-Adha ?'),
    (215, N'fiqh', N'avance', N'Quel est le statut de l''intérêt usuraire (Riba) en Islam ?'),
    (216, N'fiqh', N'avance', N'Que signifie ''Makruh'' en Fiqh ?'),
    (217, N'fiqh', N'avance', N'Que signifie ''Mubah'' en Fiqh ?'),
    (218, N'fiqh', N'avance', N'Quel imam est le fondateur de l''école hanafite ?'),
    (219, N'fiqh', N'avance', N'Quel imam est le fondateur de l''école malikite ?'),
    (220, N'fiqh', N'avance', N'Quel imam est le fondateur de l''école chafi''ite ?'),
    (221, N'fiqh', N'avance', N'Quel imam est le fondateur de l''école hanbalite ?'),
    (222, N'fiqh', N'avance', N'Quelle école juridique est dominante au Maroc ?'),
    (223, N'fiqh', N'avance', N'Quelles sont les deux sources premières et fondamentales du Fiqh ?'),
    (224, N'fiqh', N'avance', N'Que signifie ''Ijma'''' en usul al-fiqh ?'),
    (225, N'fiqh', N'avance', N'Que signifie ''Qiyas'' en usul al-fiqh ?');

-- ======== SIRA : 75 questions ========

INSERT INTO dbo.questions (id, categorie, niveau, enonce) VALUES
    (226, N'sira', N'debutant', N'Dans quelle ville le Prophète Muhammad ﷺ est-il né ?'),
    (227, N'sira', N'debutant', N'Quelle année, marquée par la tentative d''invasion d''Abraha, correspond à la naissance du Prophète ﷺ ?'),
    (228, N'sira', N'debutant', N'Quel était le nom du père du Prophète ﷺ, mort avant sa naissance ?'),
    (229, N'sira', N'debutant', N'Quel était le nom de la mère du Prophète ﷺ, morte alors qu''il avait 6 ans ?'),
    (230, N'sira', N'debutant', N'Quel grand-père a pris soin du Prophète ﷺ après le décès de sa mère ?'),
    (231, N'sira', N'debutant', N'Quel oncle a élevé et protégé le Prophète ﷺ après le décès de son grand-père ?'),
    (232, N'sira', N'debutant', N'Comment s''appelait la nourrice de la tribu de Sa''d qui l''a élevé dans le désert ?'),
    (233, N'sira', N'debutant', N'Quel surnom les Mecquois donnaient-ils à Muhammad avant la prophétie pour son honnêteté ?'),
    (234, N'sira', N'debutant', N'Qui fut la première épouse du Prophète ﷺ et la première personne à embrasser l''Islam ?'),
    (235, N'sira', N'debutant', N'Quel âge avait le Prophète ﷺ lors de la première révélation dans la grotte de Hira ?'),
    (236, N'sira', N'debutant', N'Quel ange est venu apporter la première révélation dans la grotte de Hira ?'),
    (237, N'sira', N'debutant', N'Quel est le premier mot révélé au Prophète ﷺ dans la sourate Al-''Alaq ?'),
    (238, N'sira', N'debutant', N'Qui fut le premier homme adulte libre à embrasser l''Islam ?'),
    (239, N'sira', N'debutant', N'Qui fut le premier enfant à embrasser l''Islam, cousin du Prophète ﷺ ?'),
    (240, N'sira', N'debutant', N'Qui fut le premier muezzin de l''Islam, ancien esclave affranchi par Abu Bakr ?'),
    (241, N'sira', N'debutant', N'Où les premiers musulmans persécutés ont-ils émigré sur ordre du Prophète ﷺ ?'),
    (242, N'sira', N'debutant', N'Comment s''appelait le roi chrétien juste d''Abyssinie qui a protégé les musulmans ?'),
    (243, N'sira', N'debutant', N'Comment appelle-t-on l''année où le Prophète ﷺ a perdu Abu Talib et Khadija ?'),
    (244, N'sira', N'debutant', N'Comment s''appelle le voyage nocturne de La Mecque à Jérusalem suivi de l''ascension céleste ?'),
    (245, N'sira', N'debutant', N'De quelle ville venaient les croyants qui ont prêté serment au Prophète ﷺ à al-Aqaba ?'),
    (246, N'sira', N'debutant', N'Comment s''appelle l''émigration du Prophète ﷺ et des musulmans de La Mecque vers Médine ?'),
    (247, N'sira', N'debutant', N'Qui a accompagné le Prophète ﷺ durant l''Hégire et s''est caché avec lui dans la grotte de Thawr ?'),
    (248, N'sira', N'debutant', N'Comment s''appelaient les habitants de Médine qui ont accueilli les émigrés mecquois ?'),
    (249, N'sira', N'debutant', N'Comment s''appelaient les musulmans qui ont quitté La Mecque pour Médine ?'),
    (250, N'sira', N'debutant', N'Quelle fut la première grande bataille gagnée par les musulmans, le 17 Ramadan de l''an 2 de l''Hégire ?'),
    (251, N'sira', N'intermediaire', N'Lors de quelle bataille le Prophète ﷺ a-t-il été blessé et son oncle Hamza tué en martyr ?'),
    (252, N'sira', N'intermediaire', N'Quel compagnon d''origine perse a suggéré de creuser une tranchée (Khandaq) autour de Médine ?'),
    (253, N'sira', N'intermediaire', N'Comment s''appelle le traité de paix signé entre les musulmans et Quraysh en l''an 6 de l''Hégire ?'),
    (254, N'sira', N'intermediaire', N'En quelle année hégirienne la conquête pacifique de La Mecque (Fath Makkah) a-t-elle eu lieu ?'),
    (255, N'sira', N'intermediaire', N'À quel âge le Prophète Muhammad ﷺ est-il décédé à Médine ?'),
    (256, N'sira', N'intermediaire', N'Dans quel clan de Quraysh le Prophète ﷺ est-il né ?'),
    (257, N'sira', N'intermediaire', N'Quel âge avait le Prophète ﷺ lors de son mariage avec Khadija ?'),
    (258, N'sira', N'intermediaire', N'Combien de temps environ la mission prophétique a-t-elle duré à La Mecque ?'),
    (259, N'sira', N'intermediaire', N'Combien de temps le Prophète ﷺ a-t-il vécu à Médine après l''Hégire ?'),
    (260, N'sira', N'intermediaire', N'Quel fils du Prophète ﷺ est né de Maria al-Qibtiyya ?'),
    (261, N'sira', N'intermediaire', N'Combien de filles le Prophète ﷺ a-t-il eues ?'),
    (262, N'sira', N'intermediaire', N'Quelle fille du Prophète ﷺ a épousé Ali ibn Abi Talib ?'),
    (263, N'sira', N'intermediaire', N'Quel compagnon, surnommé Dhun-Nurayn, a épousé deux filles du Prophète ﷺ ?'),
    (264, N'sira', N'intermediaire', N'Qui fut la première martyre de l''Islam, morte sous la torture à La Mecque ?'),
    (265, N'sira', N'intermediaire', N'Quel oncle du Prophète ﷺ, surnommé « le Lion d''Allah », a embrassé l''Islam ?'),
    (266, N'sira', N'intermediaire', N'Quel oncle du Prophète ﷺ s''est violemment opposé à lui et est cité dans le Coran ?'),
    (267, N'sira', N'intermediaire', N'Comment s''appelle le lieu où les Banu Hashim ont subi le boycott de Quraysh ?'),
    (268, N'sira', N'intermediaire', N'Quelle maison servit de premier lieu d''enseignement discret aux premiers musulmans ?'),
    (269, N'sira', N'intermediaire', N'Dans quelle ville le Prophète ﷺ a-t-il été rejeté et lapidé lorsqu''il est allé prêcher ?'),
    (270, N'sira', N'intermediaire', N'Quelle est la première mosquée construite par le Prophète ﷺ à son arrivée près de Médine ?'),
    (271, N'sira', N'intermediaire', N'Vers quelle direction les musulmans priaient-ils avant le changement de Qibla vers la Ka''ba ?'),
    (272, N'sira', N'intermediaire', N'Comment s''appelle la fraternisation instaurée entre Muhajirun et Ansar à Médine ?'),
    (273, N'sira', N'intermediaire', N'Combien de musulmans environ ont combattu à la bataille de Badr ?'),
    (274, N'sira', N'intermediaire', N'En quelle année hégirienne a eu lieu la bataille d''Uhud ?'),
    (275, N'sira', N'intermediaire', N'Quelle bataille est aussi appelée la bataille des Coalisés (Al-Ahzab) ?'),
    (276, N'sira', N'avance', N'Quelle bataille contre des forteresses juives au nord de Médine a eu lieu en l''an 7 ?'),
    (277, N'sira', N'avance', N'Quel compagnon, surnommé « l''Épée d''Allah », s''est illustré à Mu''ta ?'),
    (278, N'sira', N'avance', N'Quelle bataille a eu lieu peu après la conquête de La Mecque contre Hawazin et Thaqif ?'),
    (279, N'sira', N'avance', N'Quelle est la dernière expédition dirigée par le Prophète ﷺ, en l''an 9 vers le nord ?'),
    (280, N'sira', N'avance', N'En quelle année hégirienne a eu lieu le pèlerinage d''adieu ?'),
    (281, N'sira', N'avance', N'Dans quel lieu le Prophète ﷺ a-t-il prononcé son sermon d''adieu ?'),
    (282, N'sira', N'avance', N'Qui fut le premier calife après la mort du Prophète ﷺ ?'),
    (283, N'sira', N'avance', N'Comment s''appelle la chamelle du Prophète ﷺ pendant l''Hégire ?'),
    (284, N'sira', N'avance', N'Comment s''appelle la monture du Prophète ﷺ lors du voyage nocturne (Isra) ?'),
    (285, N'sira', N'avance', N'Quel compagnon fut envoyé à Médine pour y enseigner l''Islam avant l''Hégire ?'),
    (286, N'sira', N'avance', N'Quel compagnon est surnommé « l''homme de confiance de cette communauté » ?'),
    (287, N'sira', N'avance', N'Combien de compagnons sont appelés « les Dix promis au Paradis » ?'),
    (288, N'sira', N'avance', N'Quel compagnon est surnommé « Al-Farouq », celui qui distingue le vrai du faux ?'),
    (289, N'sira', N'avance', N'Qui fut l''épouse du Prophète ﷺ après le décès de Khadija ?'),
    (290, N'sira', N'avance', N'Quelle épouse du Prophète ﷺ était la fille d''Abu Bakr ?'),
    (291, N'sira', N'avance', N'Quelle épouse du Prophète ﷺ était la fille d''Omar ibn al-Khattab ?'),
    (292, N'sira', N'avance', N'Quel compagnon a émigré le premier en Abyssinie avec son épouse Ruqayya ?'),
    (293, N'sira', N'avance', N'Quel compagnon a plaidé la cause des musulmans devant le Négus ?'),
    (294, N'sira', N'avance', N'Comment s''appelle le serment prêté sous un arbre avant le traité d''Al-Hudaybiyyah ?'),
    (295, N'sira', N'avance', N'Qui a lancé l''Adhan depuis le toit de la Ka''ba lors de la conquête de La Mecque ?'),
    (296, N'sira', N'avance', N'Quel souverain perse a déchiré la lettre du Prophète ﷺ ?'),
    (297, N'sira', N'avance', N'Quel gouverneur d''Égypte a envoyé Maria al-Qibtiyya en cadeau au Prophète ﷺ ?'),
    (298, N'sira', N'avance', N'Dans la maison de quelle épouse le Prophète ﷺ est-il décédé ?'),
    (299, N'sira', N'avance', N'Quel compagnon a dormi dans le lit du Prophète ﷺ la nuit de l''Hégire ?'),
    (300, N'sira', N'avance', N'Quelles tribus de Médine formaient les Ansar ?');


-- ---- choix ----

-- Q1 (coran/debutant) : bonne réponse = 114

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (1, N'120', 0),
    (1, N'114', 1),
    (1, N'110', 0),
    (1, N'112', 0);

-- Q2 (coran/debutant) : bonne réponse = Al-Fatiha

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (2, N'Al-Ikhlas', 0),
    (2, N'An-Nas', 0),
    (2, N'Al-Baqarah', 0),
    (2, N'Al-Fatiha', 1);

-- Q3 (coran/debutant) : bonne réponse = Al-Baqarah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (3, N'Yasin', 0),
    (3, N'Al-Baqarah', 1),
    (3, N'Al-Kahf', 0),
    (3, N'Al-Fatiha', 0);

-- Q4 (coran/debutant) : bonne réponse = Al-Kawthar

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (4, N'An-Nas', 0),
    (4, N'Al-Kawthar', 1),
    (4, N'Al-Falaq', 0),
    (4, N'Al-Ikhlas', 0);

-- Q5 (coran/debutant) : bonne réponse = At-Tawbah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (5, N'At-Tawbah', 1),
    (5, N'Al-Anfal', 0),
    (5, N'Al-Fatiha', 0),
    (5, N'Yasin', 0);

-- Q6 (coran/debutant) : bonne réponse = An-Naml

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (6, N'An-Nisa', 0),
    (6, N'Al-Ma''idah', 0),
    (6, N'Al-Baqarah', 0),
    (6, N'An-Naml', 1);

-- Q7 (coran/debutant) : bonne réponse = Le verset de la dette (Ayat ad-Dayn)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (7, N'Le premier verset d''Al-Fatiha', 0),
    (7, N'Le verset de la lumière (Ayat an-Nur)', 0),
    (7, N'Le verset de la dette (Ayat ad-Dayn)', 1),
    (7, N'Ayat al-Kursi', 0);

-- Q8 (coran/debutant) : bonne réponse = Al-Baqarah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (8, N'Al-Baqarah', 1),
    (8, N'Yasin', 0),
    (8, N'An-Nisa', 0),
    (8, N'Aal ''Imran', 0);

-- Q9 (coran/debutant) : bonne réponse = 30

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (9, N'30', 1),
    (9, N'114', 0),
    (9, N'60', 0),
    (9, N'15', 0);

-- Q10 (coran/debutant) : bonne réponse = 60

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (10, N'30', 0),
    (10, N'120', 0),
    (10, N'114', 0),
    (10, N'60', 1);

-- Q11 (coran/debutant) : bonne réponse = Al-Fatiha

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (11, N'Al-Fatiha', 1),
    (11, N'Al-Ikhlas', 0),
    (11, N'Al-Baqarah', 0),
    (11, N'Yasin', 0);

-- Q12 (coran/debutant) : bonne réponse = Al-Ikhlas

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (12, N'Al-Ikhlas', 1),
    (12, N'Al-Falaq', 0),
    (12, N'An-Nas', 0),
    (12, N'Al-Fatiha', 0);

-- Q13 (coran/debutant) : bonne réponse = Al-Falaq et An-Nas

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (13, N'Al-Baqarah et Aal ''Imran', 0),
    (13, N'Al-Falaq et An-Nas', 1),
    (13, N'Yasin et Al-Mulk', 0),
    (13, N'Al-Fatiha et Al-Ikhlas', 0);

-- Q14 (coran/debutant) : bonne réponse = Sourate Youssef

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (14, N'Sourate Ibrahim', 0),
    (14, N'Sourate Younus', 0),
    (14, N'Sourate Houd', 0),
    (14, N'Sourate Youssef', 1);

-- Q15 (coran/debutant) : bonne réponse = Moussa (Moïse)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (15, N'Issa', 0),
    (15, N'Muhammad', 0),
    (15, N'Moussa (Moïse)', 1),
    (15, N'Ibrahim', 0);

-- Q16 (coran/debutant) : bonne réponse = Maryam (Marie)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (16, N'Maryam (Marie)', 1),
    (16, N'Khadija', 0),
    (16, N'Aasiya', 0),
    (16, N'Aïcha', 0);

-- Q17 (coran/debutant) : bonne réponse = Al-Kahf

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (17, N'Al-Kahf', 1),
    (17, N'Taha', 0),
    (17, N'Al-Anbiya', 0),
    (17, N'Al-Isra', 0);

-- Q18 (coran/debutant) : bonne réponse = Ibrahim (Abraham)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (18, N'Adam', 0),
    (18, N'Nuh', 0),
    (18, N'Ibrahim (Abraham)', 1),
    (18, N'Moussa', 0);

-- Q19 (coran/debutant) : bonne réponse = At-Tin (Le Figuier)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (19, N'An-Nur', 0),
    (19, N'Al-Baqarah', 0),
    (19, N'An-Nahl', 0),
    (19, N'At-Tin (Le Figuier)', 1);

-- Q20 (coran/debutant) : bonne réponse = La révélation du Coran

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (20, N'La conquête de La Mecque', 0),
    (20, N'La révélation du Coran', 1),
    (20, N'La naissance du Prophète', 0),
    (20, N'L''Hégire', 0);

-- Q21 (coran/debutant) : bonne réponse = 23 ans

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (21, N'23 ans', 1),
    (21, N'30 ans', 0),
    (21, N'10 ans', 0),
    (21, N'40 ans', 0);

-- Q22 (coran/debutant) : bonne réponse = Médine

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (22, N'La Mecque', 0),
    (22, N'Taïf', 0),
    (22, N'Médine', 1),
    (22, N'Jérusalem', 0);

-- Q23 (coran/debutant) : bonne réponse = La Mecque

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (23, N'Médine', 0),
    (23, N'Sanaa', 0),
    (23, N'La Mecque', 1),
    (23, N'Damas', 0);

-- Q24 (coran/debutant) : bonne réponse = Zaïd ibn Harithah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (24, N'Omar ibn al-Khattab', 0),
    (24, N'Zaïd ibn Harithah', 1),
    (24, N'Ali ibn Abi Talib', 0),
    (24, N'Abu Bakr', 0);

-- Q25 (coran/debutant) : bonne réponse = Yasin

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (25, N'Al-Mulk', 0),
    (25, N'Al-Fatiha', 0),
    (25, N'Yasin', 1),
    (25, N'Ar-Rahman', 0);

-- Q26 (coran/intermediaire) : bonne réponse = Al-Isra

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (26, N'Al-Fath', 0),
    (26, N'Al-Isra', 1),
    (26, N'Al-Qadr', 0),
    (26, N'An-Najm', 0);

-- Q27 (coran/intermediaire) : bonne réponse = 'Issa (Jésus)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (27, N'''Issa (Jésus)', 1),
    (27, N'Yahya', 0),
    (27, N'Ibrahim', 0),
    (27, N'Moussa', 0);

-- Q28 (coran/intermediaire) : bonne réponse = Le peuple de Moussa (Bani Isra'il)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (28, N'Le peuple de Nuh', 0),
    (28, N'Le peuple de Houd', 0),
    (28, N'Le peuple de Salih', 0),
    (28, N'Le peuple de Moussa (Bani Isra''il)', 1);

-- Q29 (coran/intermediaire) : bonne réponse = Younus (Jonas)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (29, N'Ayyub', 0),
    (29, N'Youssef', 0),
    (29, N'Zakariya', 0),
    (29, N'Younus (Jonas)', 1);

-- Q30 (coran/intermediaire) : bonne réponse = Ayyub (Job)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (30, N'Nuh', 0),
    (30, N'Ayyub (Job)', 1),
    (30, N'Moussa', 0),
    (30, N'Ibrahim', 0);

-- Q31 (coran/intermediaire) : bonne réponse = 3

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (31, N'4', 0),
    (31, N'13', 0),
    (31, N'2', 0),
    (31, N'3', 1);

-- Q32 (coran/intermediaire) : bonne réponse = 4

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (32, N'3', 0),
    (32, N'5', 0),
    (32, N'14', 0),
    (32, N'4', 1);

-- Q33 (coran/intermediaire) : bonne réponse = 5

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (33, N'15', 0),
    (33, N'5', 1),
    (33, N'6', 0),
    (33, N'4', 0);

-- Q34 (coran/intermediaire) : bonne réponse = 6

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (34, N'5', 0),
    (34, N'6', 1),
    (34, N'16', 0),
    (34, N'7', 0);

-- Q35 (coran/intermediaire) : bonne réponse = 7

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (35, N'17', 0),
    (35, N'6', 0),
    (35, N'7', 1),
    (35, N'8', 0);

-- Q36 (coran/intermediaire) : bonne réponse = 8

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (36, N'7', 0),
    (36, N'18', 0),
    (36, N'8', 1),
    (36, N'9', 0);

-- Q37 (coran/intermediaire) : bonne réponse = 10

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (37, N'9', 0),
    (37, N'20', 0),
    (37, N'11', 0),
    (37, N'10', 1);

-- Q38 (coran/intermediaire) : bonne réponse = 11

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (38, N'12', 0),
    (38, N'11', 1),
    (38, N'10', 0),
    (38, N'21', 0);

-- Q39 (coran/intermediaire) : bonne réponse = 12

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (39, N'12', 1),
    (39, N'13', 0),
    (39, N'22', 0),
    (39, N'11', 0);

-- Q40 (coran/intermediaire) : bonne réponse = 13

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (40, N'12', 0),
    (40, N'13', 1),
    (40, N'14', 0),
    (40, N'23', 0);

-- Q41 (coran/intermediaire) : bonne réponse = 14

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (41, N'15', 0),
    (41, N'14', 1),
    (41, N'13', 0),
    (41, N'24', 0);

-- Q42 (coran/intermediaire) : bonne réponse = 15

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (42, N'16', 0),
    (42, N'14', 0),
    (42, N'25', 0),
    (42, N'15', 1);

-- Q43 (coran/intermediaire) : bonne réponse = 16

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (43, N'17', 0),
    (43, N'26', 0),
    (43, N'15', 0),
    (43, N'16', 1);

-- Q44 (coran/intermediaire) : bonne réponse = 17

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (44, N'16', 0),
    (44, N'17', 1),
    (44, N'18', 0),
    (44, N'27', 0);

-- Q45 (coran/intermediaire) : bonne réponse = 18

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (45, N'18', 1),
    (45, N'28', 0),
    (45, N'17', 0),
    (45, N'19', 0);

-- Q46 (coran/intermediaire) : bonne réponse = 19

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (46, N'20', 0),
    (46, N'29', 0),
    (46, N'18', 0),
    (46, N'19', 1);

-- Q47 (coran/intermediaire) : bonne réponse = 20

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (47, N'30', 0),
    (47, N'19', 0),
    (47, N'20', 1),
    (47, N'21', 0);

-- Q48 (coran/intermediaire) : bonne réponse = 21

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (48, N'31', 0),
    (48, N'20', 0),
    (48, N'21', 1),
    (48, N'22', 0);

-- Q49 (coran/intermediaire) : bonne réponse = 22

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (49, N'32', 0),
    (49, N'23', 0),
    (49, N'21', 0),
    (49, N'22', 1);

-- Q50 (coran/intermediaire) : bonne réponse = 23

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (50, N'23', 1),
    (50, N'24', 0),
    (50, N'22', 0),
    (50, N'33', 0);

-- Q51 (coran/avance) : bonne réponse = 24

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (51, N'34', 0),
    (51, N'24', 1),
    (51, N'25', 0),
    (51, N'23', 0);

-- Q52 (coran/avance) : bonne réponse = 25

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (52, N'35', 0),
    (52, N'24', 0),
    (52, N'25', 1),
    (52, N'26', 0);

-- Q53 (coran/avance) : bonne réponse = 26

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (53, N'26', 1),
    (53, N'27', 0),
    (53, N'36', 0),
    (53, N'25', 0);

-- Q54 (coran/avance) : bonne réponse = 27

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (54, N'27', 1),
    (54, N'28', 0),
    (54, N'37', 0),
    (54, N'26', 0);

-- Q55 (coran/avance) : bonne réponse = 28

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (55, N'27', 0),
    (55, N'29', 0),
    (55, N'38', 0),
    (55, N'28', 1);

-- Q56 (coran/avance) : bonne réponse = 29

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (56, N'39', 0),
    (56, N'30', 0),
    (56, N'28', 0),
    (56, N'29', 1);

-- Q57 (coran/avance) : bonne réponse = 30

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (57, N'31', 0),
    (57, N'40', 0),
    (57, N'29', 0),
    (57, N'30', 1);

-- Q58 (coran/avance) : bonne réponse = 31

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (58, N'41', 0),
    (58, N'32', 0),
    (58, N'31', 1),
    (58, N'30', 0);

-- Q59 (coran/avance) : bonne réponse = 32

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (59, N'33', 0),
    (59, N'42', 0),
    (59, N'32', 1),
    (59, N'31', 0);

-- Q60 (coran/avance) : bonne réponse = 33

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (60, N'43', 0),
    (60, N'33', 1),
    (60, N'32', 0),
    (60, N'34', 0);

-- Q61 (coran/avance) : bonne réponse = 34

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (61, N'33', 0),
    (61, N'35', 0),
    (61, N'34', 1),
    (61, N'44', 0);

-- Q62 (coran/avance) : bonne réponse = 35

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (62, N'45', 0),
    (62, N'36', 0),
    (62, N'35', 1),
    (62, N'34', 0);

-- Q63 (coran/avance) : bonne réponse = 36

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (63, N'36', 1),
    (63, N'37', 0),
    (63, N'35', 0),
    (63, N'46', 0);

-- Q64 (coran/avance) : bonne réponse = 37

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (64, N'38', 0),
    (64, N'36', 0),
    (64, N'37', 1),
    (64, N'47', 0);

-- Q65 (coran/avance) : bonne réponse = 38

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (65, N'38', 1),
    (65, N'39', 0),
    (65, N'37', 0),
    (65, N'48', 0);

-- Q66 (coran/avance) : bonne réponse = 39

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (66, N'49', 0),
    (66, N'40', 0),
    (66, N'38', 0),
    (66, N'39', 1);

-- Q67 (coran/avance) : bonne réponse = 40

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (67, N'41', 0),
    (67, N'39', 0),
    (67, N'50', 0),
    (67, N'40', 1);

-- Q68 (coran/avance) : bonne réponse = 41

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (68, N'40', 0),
    (68, N'41', 1),
    (68, N'42', 0),
    (68, N'51', 0);

-- Q69 (coran/avance) : bonne réponse = 42

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (69, N'41', 0),
    (69, N'43', 0),
    (69, N'52', 0),
    (69, N'42', 1);

-- Q70 (coran/avance) : bonne réponse = 43

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (70, N'53', 0),
    (70, N'44', 0),
    (70, N'42', 0),
    (70, N'43', 1);

-- Q71 (coran/avance) : bonne réponse = 44

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (71, N'43', 0),
    (71, N'44', 1),
    (71, N'54', 0),
    (71, N'45', 0);

-- Q72 (coran/avance) : bonne réponse = 45

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (72, N'44', 0),
    (72, N'55', 0),
    (72, N'46', 0),
    (72, N'45', 1);

-- Q73 (coran/avance) : bonne réponse = 46

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (73, N'56', 0),
    (73, N'45', 0),
    (73, N'46', 1),
    (73, N'47', 0);

-- Q74 (coran/avance) : bonne réponse = 47

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (74, N'48', 0),
    (74, N'57', 0),
    (74, N'46', 0),
    (74, N'47', 1);

-- Q75 (coran/avance) : bonne réponse = 48

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (75, N'48', 1),
    (75, N'47', 0),
    (75, N'49', 0),
    (75, N'58', 0);

-- Q76 (hadith/debutant) : bonne réponse = Les intentions (An-Niyyah)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (76, N'Les intentions (An-Niyyah)', 1),
    (76, N'La richesse', 0),
    (76, N'La force physique', 0),
    (76, N'La réputation', 0);

-- Q77 (hadith/debutant) : bonne réponse = L'Imam Al-Bukhari

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (77, N'L''Imam Ash-Shafi''i', 0),
    (77, N'L''Imam Al-Bukhari', 1),
    (77, N'L''Imam Malik', 0),
    (77, N'L''Imam Ahmad', 0);

-- Q78 (hadith/debutant) : bonne réponse = Sahih Muslim

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (78, N'Sunan at-Tirmidhi', 0),
    (78, N'Sunan an-Nasa''i', 0),
    (78, N'Sahih Muslim', 1),
    (78, N'Sunan Abu Dawud', 0);

-- Q79 (hadith/debutant) : bonne réponse = Les Sahihayn

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (79, N'Les Sahihayn', 1),
    (79, N'Al-Muwatta', 0),
    (79, N'Les Sunan', 0),
    (79, N'Al-Musnad', 0);

-- Q80 (hadith/debutant) : bonne réponse = Une parole divine rapportée par le Prophète ﷺ avec ses propres mots

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (80, N'Une parole divine rapportée par le Prophète ﷺ avec ses propres mots', 1),
    (80, N'Le récit d''un compagnon', 0),
    (80, N'Un verset du Coran', 0),
    (80, N'Un poème ancien', 0);

-- Q81 (hadith/debutant) : bonne réponse = Abu Hurairah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (81, N'Abu Hurairah', 1),
    (81, N'Anas ibn Malik', 0),
    (81, N'Ali ibn Abi Talib', 0),
    (81, N'Omar ibn al-Khattab', 0);

-- Q82 (hadith/debutant) : bonne réponse = Anas ibn Malik

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (82, N'Anas ibn Malik', 1),
    (82, N'Zaïd ibn Thabit', 0),
    (82, N'Abu Bakr', 0),
    (82, N'Ibn Abbas', 0);

-- Q83 (hadith/debutant) : bonne réponse = Aïcha bint Abu Bakr

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (83, N'Khadija bint Khuwaylid', 0),
    (83, N'Aïcha bint Abu Bakr', 1),
    (83, N'Umm Salama', 0),
    (83, N'Hafsa bint Omar', 0);

-- Q84 (hadith/debutant) : bonne réponse = L'Islam, l'Iman et l'Ihsan

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (84, N'La prière, le jeûne et la zakat', 0),
    (84, N'Le Coran, la Sunnah et le Fiqh', 0),
    (84, N'L''Islam, l''Iman et l''Ihsan', 1),
    (84, N'La foi, le savoir et l''action', 0);

-- Q85 (hadith/debutant) : bonne réponse = Adorer Allah comme si tu Le voyais, car si tu ne Le vois pas, Lui te voit

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (85, N'Donner l''aumône aux pauvres', 0),
    (85, N'Adorer Allah comme si tu Le voyais, car si tu ne Le vois pas, Lui te voit', 1),
    (85, N'Faire le pèlerinage chaque année', 0),
    (85, N'Apprendre le Coran par cœur', 0);

-- Q86 (hadith/debutant) : bonne réponse = 5 piliers

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (86, N'7 piliers', 0),
    (86, N'6 piliers', 0),
    (86, N'4 piliers', 0),
    (86, N'5 piliers', 1);

-- Q87 (hadith/debutant) : bonne réponse = 6 piliers

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (87, N'3 piliers', 0),
    (87, N'6 piliers', 1),
    (87, N'7 piliers', 0),
    (87, N'5 piliers', 0);

-- Q88 (hadith/debutant) : bonne réponse = ...le Coran et l'enseigne

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (88, N'...la poésie', 0),
    (88, N'...le commerce', 0),
    (88, N'...le Coran et l''enseigne', 1),
    (88, N'...la guerre', 0);

-- Q89 (hadith/debutant) : bonne réponse = ...ce qu'il aime pour lui-même

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (89, N'...sa richesse', 0),
    (89, N'...sa santé', 0),
    (89, N'...sa maison', 0),
    (89, N'...ce qu''il aime pour lui-même', 1);

-- Q90 (hadith/debutant) : bonne réponse = ...une obligation pour chaque musulman

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (90, N'...une option facultative', 0),
    (90, N'...une obligation pour chaque musulman', 1),
    (90, N'...interdite', 0),
    (90, N'...réservée aux vieillards', 0);

-- Q91 (hadith/debutant) : bonne réponse = ...la moitié de la foi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (91, N'...facultative', 0),
    (91, N'...un luxe', 0),
    (91, N'...un devoir hebdomadaire', 0),
    (91, N'...la moitié de la foi', 1);

-- Q92 (hadith/debutant) : bonne réponse = Usama ibn Zayd

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (92, N'Usama ibn Zayd', 1),
    (92, N'Bilal ibn Rabah', 0),
    (92, N'Abu Dharr', 0),
    (92, N'Khalid ibn al-Walid', 0);

-- Q93 (hadith/debutant) : bonne réponse = ...amère

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (93, N'...amère', 1),
    (93, N'...cachée', 0),
    (93, N'...facile', 0),
    (93, N'...douce', 0);

-- Q94 (hadith/debutant) : bonne réponse = L'Imam An-Nawawi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (94, N'Ibn Taymiyyah', 0),
    (94, N'L''Imam Al-Ghazali', 0),
    (94, N'L''Imam An-Nawawi', 1),
    (94, N'Ibn Kathir', 0);

-- Q95 (hadith/debutant) : bonne réponse = Le changer de sa main, sinon de sa langue, sinon le désapprouver en son cœur

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (95, N'Le photographier', 0),
    (95, N'Le changer de sa main, sinon de sa langue, sinon le désapprouver en son cœur', 1),
    (95, N'L''ignorer complètement', 0),
    (95, N'Fuir le pays', 0);

-- Q96 (hadith/debutant) : bonne réponse = Isnad

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (96, N'Isnad', 1),
    (96, N'Fiqh', 0),
    (96, N'Tafsir', 0),
    (96, N'Matn', 0);

-- Q97 (hadith/debutant) : bonne réponse = Matn

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (97, N'Matn', 1),
    (97, N'Tafsir', 0),
    (97, N'Isnad', 0),
    (97, N'Sira', 0);

-- Q98 (hadith/debutant) : bonne réponse = Sahih

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (98, N'Da''if', 0),
    (98, N'Sahih', 1),
    (98, N'Mawdu''', 0),
    (98, N'Gharib', 0);

-- Q99 (hadith/debutant) : bonne réponse = Mawdu'

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (99, N'Sahih', 0),
    (99, N'Mawdu''', 1),
    (99, N'Mutawatir', 0),
    (99, N'Hasan', 0);

-- Q100 (hadith/debutant) : bonne réponse = Al-Muwatta

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (100, N'Al-Muwatta', 1),
    (100, N'Sahih', 0),
    (100, N'Sunan', 0),
    (100, N'Al-Musnad', 0);

-- Q101 (hadith/intermediaire) : bonne réponse = ...maîtrise sa colère

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (101, N'...maîtrise sa colère', 1),
    (101, N'...court vite', 0),
    (101, N'...gagne beaucoup d''argent', 0),
    (101, N'...parle fort', 0);

-- Q102 (hadith/intermediaire) : bonne réponse = Ne te mets pas en colère

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (102, N'Ne te mets pas en colère', 1),
    (102, N'Achète beaucoup de biens', 0),
    (102, N'Voyage beaucoup', 0),
    (102, N'Jeûne tous les jours', 0);

-- Q103 (hadith/intermediaire) : bonne réponse = Avec bienfaisance, respect et sans lui nuire

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (103, N'En l''ignorant', 0),
    (103, N'Avec bienfaisance, respect et sans lui nuire', 1),
    (103, N'En lui achetant sa maison', 0),
    (103, N'En l''enviant', 0);

-- Q104 (hadith/intermediaire) : bonne réponse = ...aumône (Sadaqa)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (104, N'...obligation légale', 0),
    (104, N'...erreur', 0),
    (104, N'...perte de temps', 0),
    (104, N'...aumône (Sadaqa)', 1);

-- Q105 (hadith/intermediaire) : bonne réponse = ...en bonne santé et avide de la vie

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (105, N'...riche et âgé', 0),
    (105, N'...en bonne santé et avide de la vie', 1),
    (105, N'...malade au lit', 0),
    (105, N'...endormi', 0);

-- Q106 (hadith/intermediaire) : bonne réponse = L'Imam An-Nawawi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (106, N'Ibn Kathir', 0),
    (106, N'Ibn Hajar al-Asqalani', 0),
    (106, N'L''Imam An-Nawawi', 1),
    (106, N'L''Imam Al-Ghazali', 0);

-- Q107 (hadith/intermediaire) : bonne réponse = Ibn Hajar al-Asqalani

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (107, N'Ibn Hajar al-Asqalani', 1),
    (107, N'Adh-Dhahabi', 0),
    (107, N'Ibn Kathir', 0),
    (107, N'L''Imam An-Nawawi', 0);

-- Q108 (hadith/intermediaire) : bonne réponse = Muhammad ibn Isma'il

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (108, N'Yahya ibn Sharaf', 0),
    (108, N'Muhammad ibn Isma''il', 1),
    (108, N'Muslim ibn al-Hajjaj', 0),
    (108, N'Ahmad ibn Muhammad', 0);

-- Q109 (hadith/intermediaire) : bonne réponse = Muslim ibn al-Hajjaj an-Naysaburi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (109, N'Abu Dawud as-Sijistani', 0),
    (109, N'Muhammad ibn Isma''il al-Bukhari', 0),
    (109, N'Muslim ibn al-Hajjaj an-Naysaburi', 1),
    (109, N'Ahmad ibn Hanbal', 0);

-- Q110 (hadith/intermediaire) : bonne réponse = Ahmad ibn Hanbal

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (110, N'Ash-Shafi''i', 0),
    (110, N'Ahmad ibn Hanbal', 1),
    (110, N'Malik ibn Anas', 0),
    (110, N'Abu Hanifa', 0);

-- Q111 (hadith/intermediaire) : bonne réponse = Les six grands recueils de hadiths

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (111, N'Les six grands recueils de hadiths', 1),
    (111, N'Les six jours de jeûne de Shawwal', 0),
    (111, N'Les six écoles juridiques', 0),
    (111, N'Les six piliers de la foi', 0);

-- Q112 (hadith/intermediaire) : bonne réponse = Mutawatir

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (112, N'Mutawatir', 1),
    (112, N'Ahad', 0),
    (112, N'Gharib', 0),
    (112, N'Mawdu''', 0);

-- Q113 (hadith/intermediaire) : bonne réponse = Da'if (faible)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (113, N'Mutawatir', 0),
    (113, N'Sahih', 0),
    (113, N'Hasan', 0),
    (113, N'Da''if (faible)', 1);

-- Q114 (hadith/intermediaire) : bonne réponse = Hasan

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (114, N'Mutawatir', 0),
    (114, N'Hasan', 1),
    (114, N'Da''if', 0),
    (114, N'Mawdu''', 0);

-- Q115 (hadith/intermediaire) : bonne réponse = Gharib

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (115, N'Mutawatir', 0),
    (115, N'Sahih', 0),
    (115, N'Gharib', 1),
    (115, N'Mashhur', 0);

-- Q116 (hadith/intermediaire) : bonne réponse = Rawi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (116, N'Mufti', 0),
    (116, N'Mufassir', 0),
    (116, N'Rawi', 1),
    (116, N'Qadi', 0);

-- Q117 (hadith/intermediaire) : bonne réponse = Muhaddith

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (117, N'Qari''', 0),
    (117, N'Faqih', 0),
    (117, N'Muhaddith', 1),
    (117, N'Mufassir', 0);

-- Q118 (hadith/intermediaire) : bonne réponse = La double attestation de foi (Shahada)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (118, N'Le jeûne', 0),
    (118, N'La double attestation de foi (Shahada)', 1),
    (118, N'Le pèlerinage', 0),
    (118, N'La prière', 0);

-- Q119 (hadith/intermediaire) : bonne réponse = ...se taise

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (119, N'...s''en aille', 0),
    (119, N'...se venge', 0),
    (119, N'...se taise', 1),
    (119, N'...s''éloigne', 0);

-- Q120 (hadith/intermediaire) : bonne réponse = ...difficiles

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (120, N'...chères', 0),
    (120, N'...secrètes', 0),
    (120, N'...difficiles', 1),
    (120, N'...courtes', 0);

-- Q121 (hadith/intermediaire) : bonne réponse = ...le bon conseil (An-Nasiha)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (121, N'...la richesse', 0),
    (121, N'...le jeûne', 0),
    (121, N'...l''épée', 0),
    (121, N'...le bon conseil (An-Nasiha)', 1);

-- Q122 (hadith/intermediaire) : bonne réponse = ...frères

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (122, N'...frères', 1),
    (122, N'...étrangers', 0),
    (122, N'...voisins', 0),
    (122, N'...rivaux', 0);

-- Q123 (hadith/intermediaire) : bonne réponse = La prière accomplie à son heure

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (123, N'La veille de la nuit entière', 0),
    (123, N'Le jeûne de tous les jours', 0),
    (123, N'Le pèlerinage chaque année', 0),
    (123, N'La prière accomplie à son heure', 1);

-- Q124 (hadith/intermediaire) : bonne réponse = Ta mère

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (124, N'Ton père', 0),
    (124, N'Ta mère', 1),
    (124, N'Ton voisin', 0),
    (124, N'Ton frère', 0);

-- Q125 (hadith/intermediaire) : bonne réponse = ...la foi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (125, N'...la science', 0),
    (125, N'...l''art', 0),
    (125, N'...la foi', 1),
    (125, N'...la richesse', 0);

-- Q126 (hadith/avance) : bonne réponse = Dire « La ilaha illa Allah »

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (126, N'Retirer une nuisance du chemin', 0),
    (126, N'Faire l''aumône', 0),
    (126, N'Jeûner', 0),
    (126, N'Dire « La ilaha illa Allah »', 1);

-- Q127 (hadith/avance) : bonne réponse = « Yarhamuk Allah »

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (127, N'« Barak Allahu fik »', 0),
    (127, N'« Subhan Allah »', 0),
    (127, N'« Astaghfirullah »', 0),
    (127, N'« Yarhamuk Allah »', 1);

-- Q128 (hadith/avance) : bonne réponse = « Bismillah »

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (128, N'« Bismillah »', 1),
    (128, N'« Subhan Allah »', 0),
    (128, N'« Astaghfirullah »', 0),
    (128, N'« Allahu Akbar »', 0);

-- Q129 (hadith/avance) : bonne réponse = La main droite

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (129, N'Peu importe, selon le hadith', 0),
    (129, N'La main gauche', 0),
    (129, N'La main droite', 1),
    (129, N'Les deux mains ensemble', 0);

-- Q130 (hadith/avance) : bonne réponse = Allah prie sur lui dix fois

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (130, N'Allah prie sur lui dix fois', 1),
    (130, N'Il reçoit mille bonnes actions', 0),
    (130, N'Allah lui donne un jardin', 0),
    (130, N'Rien de particulier', 0);

-- Q131 (hadith/avance) : bonne réponse = Le vendredi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (131, N'Le dimanche', 0),
    (131, N'Le vendredi', 1),
    (131, N'Le lundi', 0),
    (131, N'Le samedi', 0);

-- Q132 (hadith/avance) : bonne réponse = Le lundi et le jeudi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (132, N'Le samedi et le dimanche', 0),
    (132, N'Le mardi et le mercredi', 0),
    (132, N'Le lundi et le jeudi', 1),
    (132, N'Le vendredi et le samedi', 0);

-- Q133 (hadith/avance) : bonne réponse = Omar ibn al-Khattab

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (133, N'Omar ibn al-Khattab', 1),
    (133, N'Ali ibn Abi Talib', 0),
    (133, N'Abu Hurairah', 0),
    (133, N'Anas ibn Malik', 0);

-- Q134 (hadith/avance) : bonne réponse = Abu Hurairah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (134, N'Abu Bakr', 0),
    (134, N'Abu Hurairah', 1),
    (134, N'Abu Dharr', 0),
    (134, N'Abu Ubayda', 0);

-- Q135 (hadith/avance) : bonne réponse = Abdullah ibn Abbas

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (135, N'Abdullah ibn Abbas', 1),
    (135, N'Abdullah ibn Omar', 0),
    (135, N'Zaïd ibn Thabit', 0),
    (135, N'Anas ibn Malik', 0);

-- Q136 (hadith/avance) : bonne réponse = 42

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (136, N'40', 0),
    (136, N'42', 1),
    (136, N'45', 0),
    (136, N'50', 0);

-- Q137 (hadith/avance) : bonne réponse = Les paroles, actes et approbations du Prophète ﷺ

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (137, N'Les avis des juristes', 0),
    (137, N'Le Coran', 0),
    (137, N'Les coutumes arabes', 0),
    (137, N'Les paroles, actes et approbations du Prophète ﷺ', 1);

-- Q138 (hadith/avance) : bonne réponse = Taqrir

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (138, N'Taqrir', 1),
    (138, N'Ijma''', 0),
    (138, N'Qiyas', 0),
    (138, N'Fatwa', 0);

-- Q139 (hadith/avance) : bonne réponse = « La ilaha illa Allah »

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (139, N'« Astaghfirullah »', 0),
    (139, N'« Subhan Allah »', 0),
    (139, N'« Allahu Akbar »', 0),
    (139, N'« La ilaha illa Allah »', 1);

-- Q140 (hadith/avance) : bonne réponse = « Subhan Allahi wa bihamdihi, Subhan Allahil-'Azim »

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (140, N'« Astaghfirullah wa atubu ilayh »', 0),
    (140, N'« La hawla wa la quwwata illa billah »', 0),
    (140, N'« Hasbunallahu wa ni''mal wakil »', 0),
    (140, N'« Subhan Allahi wa bihamdihi, Subhan Allahil-''Azim »', 1);

-- Q141 (hadith/avance) : bonne réponse = Le plus jeune salue le plus âgé

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (141, N'Le plus savant salue tout le monde', 0),
    (141, N'Le plus âgé salue le plus jeune', 0),
    (141, N'Le plus riche salue le plus pauvre', 0),
    (141, N'Le plus jeune salue le plus âgé', 1);

-- Q142 (hadith/avance) : bonne réponse = ...main

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (142, N'...famille', 0),
    (142, N'...richesse', 0),
    (142, N'...main', 1),
    (142, N'...maison', 0);

-- Q143 (hadith/avance) : bonne réponse = Celui qui vient avec prière, jeûne et zakat mais a lésé autrui

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (143, N'Celui qui n''a pas de maison', 0),
    (143, N'Celui qui n''a pas d''enfants', 0),
    (143, N'Celui qui vient avec prière, jeûne et zakat mais a lésé autrui', 1),
    (143, N'Celui qui n''a pas d''argent', 0);

-- Q144 (hadith/avance) : bonne réponse = Le croyant fort

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (144, N'Le plus âgé', 0),
    (144, N'Le plus riche', 0),
    (144, N'Le croyant fort', 1),
    (144, N'Le plus célèbre', 0);

-- Q145 (hadith/avance) : bonne réponse = ...un chemin vers le Paradis

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (145, N'...un chemin vers La Mecque', 0),
    (145, N'...un chemin vers le Paradis', 1),
    (145, N'...le commerce', 0),
    (145, N'...la richesse', 0);

-- Q146 (hadith/avance) : bonne réponse = ...un enfant pieux qui invoque pour lui

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (146, N'...un vaste héritage', 0),
    (146, N'...une tombe entretenue', 0),
    (146, N'...un enfant pieux qui invoque pour lui', 1),
    (146, N'...une grande maison', 0);

-- Q147 (hadith/avance) : bonne réponse = Mentionner de ton frère ce qu'il déteste

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (147, N'Mentionner de ton frère ce qu''il déteste', 1),
    (147, N'Mentir à son sujet uniquement', 0),
    (147, N'Prier pour lui', 0),
    (147, N'Dire la vérité en face', 0);

-- Q148 (hadith/avance) : bonne réponse = « Jazak Allahu khayran »

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (148, N'« Subhan Allah »', 0),
    (148, N'« Jazak Allahu khayran »', 1),
    (148, N'« Inna lillahi »', 0),
    (148, N'« Ma sha Allah »', 0);

-- Q149 (hadith/avance) : bonne réponse = Un dirigeant juste

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (149, N'Un grand voyageur', 0),
    (149, N'Un homme riche', 0),
    (149, N'Un commerçant', 0),
    (149, N'Un dirigeant juste', 1);

-- Q150 (hadith/avance) : bonne réponse = Il cache ses fautes en ce monde et dans l'au-delà

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (150, N'Il l''exempte de la prière', 0),
    (150, N'Il cache ses fautes en ce monde et dans l''au-delà', 1),
    (150, N'Il révèle ses fautes', 0),
    (150, N'Il le rend riche', 0);

-- Q151 (fiqh/debutant) : bonne réponse = 5 prières

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (151, N'6 prières', 0),
    (151, N'5 prières', 1),
    (151, N'4 prières', 0),
    (151, N'3 prières', 0);

-- Q152 (fiqh/debutant) : bonne réponse = La prière (Salat)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (152, N'Le Hajj', 0),
    (152, N'La prière (Salat)', 1),
    (152, N'La Zakat', 0),
    (152, N'Le jeûne (Sawm)', 0);

-- Q153 (fiqh/debutant) : bonne réponse = Les ablutions (Woudou)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (153, N'Le repas', 0),
    (153, N'Le sommeil', 0),
    (153, N'Les ablutions (Woudou)', 1),
    (153, N'Le parfum', 0);

-- Q154 (fiqh/debutant) : bonne réponse = Tayammum

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (154, N'Tayammum', 1),
    (154, N'Ghusl', 0),
    (154, N'Istinja', 0),
    (154, N'Woudou', 0);

-- Q155 (fiqh/debutant) : bonne réponse = Ghusl

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (155, N'Ghusl', 1),
    (155, N'Mas''h', 0),
    (155, N'Woudou', 0),
    (155, N'Tayammum', 0);

-- Q156 (fiqh/debutant) : bonne réponse = Fajr (2 raka'at)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (156, N'Asr', 0),
    (156, N'Fajr (2 raka''at)', 1),
    (156, N'Dhuhr', 0),
    (156, N'Maghrib', 0);

-- Q157 (fiqh/debutant) : bonne réponse = 4 Raka'at

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (157, N'2 Raka''at', 0),
    (157, N'3 Raka''at', 0),
    (157, N'4 Raka''at', 1),
    (157, N'5 Raka''at', 0);

-- Q158 (fiqh/debutant) : bonne réponse = 3 Raka'at

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (158, N'5 Raka''at', 0),
    (158, N'2 Raka''at', 0),
    (158, N'3 Raka''at', 1),
    (158, N'4 Raka''at', 0);

-- Q159 (fiqh/debutant) : bonne réponse = 4 Raka'at

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (159, N'2 Raka''at', 0),
    (159, N'3 Raka''at', 0),
    (159, N'4 Raka''at', 1),
    (159, N'5 Raka''at', 0);

-- Q160 (fiqh/debutant) : bonne réponse = La prière du vendredi (Jumu'ah)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (160, N'La prière du Tarawih', 0),
    (160, N'La prière du Janazah', 0),
    (160, N'La prière de l''Aïd', 0),
    (160, N'La prière du vendredi (Jumu''ah)', 1);

-- Q161 (fiqh/debutant) : bonne réponse = La Ka'ba à La Mecque

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (161, N'Jérusalem', 0),
    (161, N'La Ka''ba à La Mecque', 1),
    (161, N'Le soleil couchant', 0),
    (161, N'Médine', 0);

-- Q162 (fiqh/debutant) : bonne réponse = L'Adhan

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (162, N'Le Dhikr', 0),
    (162, N'L''Iqama', 0),
    (162, N'La Khutba', 0),
    (162, N'L''Adhan', 1);

-- Q163 (fiqh/debutant) : bonne réponse = L'Iqama

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (163, N'L''Adhan', 0),
    (163, N'L''Iqama', 1),
    (163, N'Le Tashahhud', 0),
    (163, N'Le Takbir', 0);

-- Q164 (fiqh/debutant) : bonne réponse = Ramadan

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (164, N'Shawwal', 0),
    (164, N'Rajab', 0),
    (164, N'Sha''ban', 0),
    (164, N'Ramadan', 1);

-- Q165 (fiqh/debutant) : bonne réponse = De l'aube (Fajr) au coucher du soleil (Maghrib)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (165, N'De midi à l''aube', 0),
    (165, N'Du lever du soleil à minuit', 0),
    (165, N'Toute la journée et toute la nuit', 0),
    (165, N'De l''aube (Fajr) au coucher du soleil (Maghrib)', 1);

-- Q166 (fiqh/debutant) : bonne réponse = Suhoor

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (166, N'Suhoor', 1),
    (166, N'Walimah', 0),
    (166, N'Aqiqah', 0),
    (166, N'Iftar', 0);

-- Q167 (fiqh/debutant) : bonne réponse = Iftar

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (167, N'Suhoor', 0),
    (167, N'Fidya', 0),
    (167, N'Iftar', 1),
    (167, N'Niyyah', 0);

-- Q168 (fiqh/debutant) : bonne réponse = La Zakat

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (168, N'La Shahada', 0),
    (168, N'Le Hajj', 0),
    (168, N'Le Sawm', 0),
    (168, N'La Zakat', 1);

-- Q169 (fiqh/debutant) : bonne réponse = 2,5 %

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (169, N'5 %', 0),
    (169, N'2,5 %', 1),
    (169, N'10 %', 0),
    (169, N'20 %', 0);

-- Q170 (fiqh/debutant) : bonne réponse = Le pèlerinage à La Mecque (Hajj)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (170, N'Le pèlerinage à La Mecque (Hajj)', 1),
    (170, N'La Zakat', 0),
    (170, N'La Umrah', 0),
    (170, N'Le Tarawih', 0);

-- Q171 (fiqh/debutant) : bonne réponse = La Umrah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (171, N'Mina', 0),
    (171, N'La Umrah', 1),
    (171, N'Le Hajj', 0),
    (171, N'Arafat', 0);

-- Q172 (fiqh/debutant) : bonne réponse = Le jour d'Arafat (9 Dhul-Hijjah)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (172, N'Le vendredi', 0),
    (172, N'Le jour de l''Aïd al-Fitr', 0),
    (172, N'Le jour d''Arafat (9 Dhul-Hijjah)', 1),
    (172, N'Le premier jour de Ramadan', 0);

-- Q173 (fiqh/debutant) : bonne réponse = Ihram

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (173, N'Ihram', 1),
    (173, N'Sa''y', 0),
    (173, N'Tawaf', 0),
    (173, N'Halq', 0);

-- Q174 (fiqh/debutant) : bonne réponse = Tawaf

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (174, N'Ihram', 0),
    (174, N'Sa''y', 0),
    (174, N'Rami', 0),
    (174, N'Tawaf', 1);

-- Q175 (fiqh/debutant) : bonne réponse = Sa'y

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (175, N'Tawaf', 0),
    (175, N'Ihram', 0),
    (175, N'Sa''y', 1),
    (175, N'Rami', 0);

-- Q176 (fiqh/intermediaire) : bonne réponse = 4 écoles

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (176, N'6 écoles', 0),
    (176, N'10 écoles', 0),
    (176, N'2 écoles', 0),
    (176, N'4 écoles', 1);

-- Q177 (fiqh/intermediaire) : bonne réponse = Hanafite, Malikite, Chafi'ite, Hanbalite

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (177, N'Hanafite, Malikite, Chafi''ite, Hanbalite', 1),
    (177, N'Ja''farite, Zaydite, Ibadhite, Zahirite', 0),
    (177, N'Mecquoise, Médinoise, Syrienne, Égyptienne', 0),
    (177, N'Sufi, Salafi, Mu''tazili, Ash''ari', 0);

-- Q178 (fiqh/intermediaire) : bonne réponse = Ce qui est permis et licite

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (178, N'Ce qui est obligatoire', 0),
    (178, N'Ce qui est interdit', 0),
    (178, N'Ce qui est détestable', 0),
    (178, N'Ce qui est permis et licite', 1);

-- Q179 (fiqh/intermediaire) : bonne réponse = Ce qui est strictement interdit

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (179, N'Ce qui est neutre', 0),
    (179, N'Ce qui est permis', 0),
    (179, N'Ce qui est strictement interdit', 1),
    (179, N'Ce qui est recommandé', 0);

-- Q180 (fiqh/intermediaire) : bonne réponse = Obligatoire

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (180, N'Permis', 0),
    (180, N'Recommandé', 0),
    (180, N'Obligatoire', 1),
    (180, N'Détestable', 0);

-- Q181 (fiqh/intermediaire) : bonne réponse = 4 Raka'at

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (181, N'3 Raka''at', 0),
    (181, N'2 Raka''at', 0),
    (181, N'5 Raka''at', 0),
    (181, N'4 Raka''at', 1);

-- Q182 (fiqh/intermediaire) : bonne réponse = 2 Raka'at

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (182, N'3 Raka''at', 0),
    (182, N'2 Raka''at', 1),
    (182, N'4 Raka''at', 0),
    (182, N'6 Raka''at', 0);

-- Q183 (fiqh/intermediaire) : bonne réponse = Le Tarawih

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (183, N'Le Janazah', 0),
    (183, N'L''Istisqa', 0),
    (183, N'Le Duha', 0),
    (183, N'Le Tarawih', 1);

-- Q184 (fiqh/intermediaire) : bonne réponse = Le Duha

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (184, N'Le Tarawih', 0),
    (184, N'Le Kusuf', 0),
    (184, N'Le Duha', 1),
    (184, N'L''Istisqa', 0);

-- Q185 (fiqh/intermediaire) : bonne réponse = Salat al-Istisqa

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (185, N'Salat al-Kusuf', 0),
    (185, N'Salat al-Istikhara', 0),
    (185, N'Salat al-Janazah', 0),
    (185, N'Salat al-Istisqa', 1);

-- Q186 (fiqh/intermediaire) : bonne réponse = Salat al-Kusuf

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (186, N'Salat al-Kusuf', 1),
    (186, N'Salat al-Istisqa', 0),
    (186, N'Le Witr', 0),
    (186, N'Le Tarawih', 0);

-- Q187 (fiqh/intermediaire) : bonne réponse = Salat al-Janazah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (187, N'La prière de l''Aïd', 0),
    (187, N'Salat al-Janazah', 1),
    (187, N'La prière de la Jumu''ah', 0),
    (187, N'Salat al-Istisqa', 0);

-- Q188 (fiqh/intermediaire) : bonne réponse = Fard kifaya (obligation collective)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (188, N'Sunnah mu''akkadah', 0),
    (188, N'Fard kifaya (obligation collective)', 1),
    (188, N'Mubah (permis)', 0),
    (188, N'Fard ''ayn (obligation individuelle)', 0);

-- Q189 (fiqh/intermediaire) : bonne réponse = Takbirat al-Ihram

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (189, N'Takbirat al-Ihram', 1),
    (189, N'Tashahhud', 0),
    (189, N'Tasleem', 0),
    (189, N'Iqama', 0);

-- Q190 (fiqh/intermediaire) : bonne réponse = « Subhana Rabbiyal-A'la »

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (190, N'« Sami''a Allahu liman hamidah »', 0),
    (190, N'« Subhana Rabbiyal-''Azim »', 0),
    (190, N'« At-tahiyyat »', 0),
    (190, N'« Subhana Rabbiyal-A''la »', 1);

-- Q191 (fiqh/intermediaire) : bonne réponse = « Subhana Rabbiyal-'Azim »

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (191, N'« Subhana Rabbiyal-''Azim »', 1),
    (191, N'« Rabbana wa lakal hamd »', 0),
    (191, N'« At-tahiyyat »', 0),
    (191, N'« Subhana Rabbiyal-A''la »', 0);

-- Q192 (fiqh/intermediaire) : bonne réponse = 2

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (192, N'4', 0),
    (192, N'2', 1),
    (192, N'1', 0),
    (192, N'3', 0);

-- Q193 (fiqh/intermediaire) : bonne réponse = Al-Fatiha

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (193, N'Al-Kawthar', 0),
    (193, N'Al-Ikhlas', 0),
    (193, N'Al-Fatiha', 1),
    (193, N'Al-Baqarah', 0);

-- Q194 (fiqh/intermediaire) : bonne réponse = Le sommeil profond

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (194, N'Se parfumer', 0),
    (194, N'Marcher', 0),
    (194, N'Parler', 0),
    (194, N'Le sommeil profond', 1);

-- Q195 (fiqh/intermediaire) : bonne réponse = La tête

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (195, N'Les mains', 0),
    (195, N'Le visage', 0),
    (195, N'La tête', 1),
    (195, N'Les avant-bras', 0);

-- Q196 (fiqh/intermediaire) : bonne réponse = Al-Mas'h 'ala al-khuffayn

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (196, N'Ghusl', 0),
    (196, N'Tayammum', 0),
    (196, N'Istinja', 0),
    (196, N'Al-Mas''h ''ala al-khuffayn', 1);

-- Q197 (fiqh/intermediaire) : bonne réponse = 3 jours et 3 nuits

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (197, N'1 jour et 1 nuit', 0),
    (197, N'5 jours', 0),
    (197, N'7 jours', 0),
    (197, N'3 jours et 3 nuits', 1);

-- Q198 (fiqh/intermediaire) : bonne réponse = 85 grammes

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (198, N'1 kilogramme', 0),
    (198, N'20 grammes', 0),
    (198, N'200 grammes', 0),
    (198, N'85 grammes', 1);

-- Q199 (fiqh/intermediaire) : bonne réponse = Avant la prière de l'Aïd

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (199, N'Avant la prière de l''Aïd', 1),
    (199, N'Après l''Aïd al-Adha', 0),
    (199, N'Pendant le Hajj', 0),
    (199, N'Au début de Rajab', 0);

-- Q200 (fiqh/intermediaire) : bonne réponse = 8

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (200, N'5', 0),
    (200, N'7', 0),
    (200, N'10', 0),
    (200, N'8', 1);

-- Q201 (fiqh/avance) : bonne réponse = 29 ou 30 jours

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (201, N'Toujours 30 jours', 0),
    (201, N'28 ou 29 jours', 0),
    (201, N'30 ou 31 jours', 0),
    (201, N'29 ou 30 jours', 1);

-- Q202 (fiqh/avance) : bonne réponse = Manger ou boire volontairement

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (202, N'Manger ou boire volontairement', 1),
    (202, N'Dormir', 0),
    (202, N'Se parfumer', 0),
    (202, N'Se laver', 0);

-- Q203 (fiqh/avance) : bonne réponse = Les dix dernières nuits, surtout les impaires

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (203, N'Le milieu du mois uniquement', 0),
    (203, N'Les dix premières nuits', 0),
    (203, N'Le premier jour', 0),
    (203, N'Les dix dernières nuits, surtout les impaires', 1);

-- Q204 (fiqh/avance) : bonne réponse = La retraite spirituelle à la mosquée

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (204, N'Le voyage vers La Mecque', 0),
    (204, N'Une aumône', 0),
    (204, N'La retraite spirituelle à la mosquée', 1),
    (204, N'Un jeûne sans manger', 0);

-- Q205 (fiqh/avance) : bonne réponse = Le 10 Dhul-Hijjah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (205, N'Le 9 Dhul-Hijjah', 0),
    (205, N'Le 10 Dhul-Hijjah', 1),
    (205, N'Le 1er Shawwal', 0),
    (205, N'Le 12 Muharram', 0);

-- Q206 (fiqh/avance) : bonne réponse = Shawwal

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (206, N'Dhul-Qa''da', 0),
    (206, N'Sha''ban', 0),
    (206, N'Rajab', 0),
    (206, N'Shawwal', 1);

-- Q207 (fiqh/avance) : bonne réponse = Dhul-Hijjah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (207, N'Ramadan', 0),
    (207, N'Dhul-Hijjah', 1),
    (207, N'Rajab', 0),
    (207, N'Muharram', 0);

-- Q208 (fiqh/avance) : bonne réponse = Ramy al-Jamarat

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (208, N'Sa''y', 0),
    (208, N'Ramy al-Jamarat', 1),
    (208, N'Ihram', 0),
    (208, N'Tawaf', 0);

-- Q209 (fiqh/avance) : bonne réponse = Muzdalifah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (209, N'Taïf', 0),
    (209, N'Médine', 0),
    (209, N'Hira', 0),
    (209, N'Muzdalifah', 1);

-- Q210 (fiqh/avance) : bonne réponse = Zamzam

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (210, N'Salsabil', 0),
    (210, N'Kawthar', 0),
    (210, N'Zamzam', 1),
    (210, N'Tasnim', 0);

-- Q211 (fiqh/avance) : bonne réponse = Le Mahr (Sadaq)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (211, N'La Nafaqa', 0),
    (211, N'Le Mahr (Sadaq)', 1),
    (211, N'La Walimah', 0),
    (211, N'Le Khul''', 0);

-- Q212 (fiqh/avance) : bonne réponse = La Walimah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (212, N'L''Aqiqah', 0),
    (212, N'La Walimah', 1),
    (212, N'L''Iftar', 0),
    (212, N'La Sadaqa', 0);

-- Q213 (fiqh/avance) : bonne réponse = L'Aqiqah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (213, N'La Fidya', 0),
    (213, N'L''Aqiqah', 1),
    (213, N'Le Hady', 0),
    (213, N'L''Udhiyah', 0);

-- Q214 (fiqh/avance) : bonne réponse = L'Udhiyah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (214, N'L''Udhiyah', 1),
    (214, N'La Kaffara', 0),
    (214, N'L''Aqiqah', 0),
    (214, N'La Zakat', 0);

-- Q215 (fiqh/avance) : bonne réponse = Haram (interdit)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (215, N'Mustahabb (recommandé)', 0),
    (215, N'Makruh (détestable)', 0),
    (215, N'Mubah (permis)', 0),
    (215, N'Haram (interdit)', 1);

-- Q216 (fiqh/avance) : bonne réponse = Détestable : mieux vaut l'éviter, sans qu'il y ait péché

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (216, N'Recommandé', 0),
    (216, N'Détestable : mieux vaut l''éviter, sans qu''il y ait péché', 1),
    (216, N'Interdit', 0),
    (216, N'Obligatoire', 0);

-- Q217 (fiqh/avance) : bonne réponse = Permis : ni récompense ni péché

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (217, N'Fard (obligatoire)', 0),
    (217, N'Sunnah (recommandé)', 0),
    (217, N'Permis : ni récompense ni péché', 1),
    (217, N'Haram (interdit)', 0);

-- Q218 (fiqh/avance) : bonne réponse = Abu Hanifa

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (218, N'Malik ibn Anas', 0),
    (218, N'Ahmad ibn Hanbal', 0),
    (218, N'Abu Hanifa', 1),
    (218, N'Ash-Shafi''i', 0);

-- Q219 (fiqh/avance) : bonne réponse = Malik ibn Anas

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (219, N'Abu Hanifa', 0),
    (219, N'Malik ibn Anas', 1),
    (219, N'Ahmad ibn Hanbal', 0),
    (219, N'Ash-Shafi''i', 0);

-- Q220 (fiqh/avance) : bonne réponse = Muhammad ibn Idris ash-Shafi'i

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (220, N'Ahmad ibn Hanbal', 0),
    (220, N'Muhammad ibn Idris ash-Shafi''i', 1),
    (220, N'Abu Hanifa', 0),
    (220, N'Malik ibn Anas', 0);

-- Q221 (fiqh/avance) : bonne réponse = Ahmad ibn Hanbal

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (221, N'Malik ibn Anas', 0),
    (221, N'Ahmad ibn Hanbal', 1),
    (221, N'Abu Hanifa', 0),
    (221, N'Ash-Shafi''i', 0);

-- Q222 (fiqh/avance) : bonne réponse = L'école malikite

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (222, N'L''école chafi''ite', 0),
    (222, N'L''école hanafite', 0),
    (222, N'L''école hanbalite', 0),
    (222, N'L''école malikite', 1);

-- Q223 (fiqh/avance) : bonne réponse = Le Coran et la Sunnah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (223, N'Le Coran et la Sunnah', 1),
    (223, N'Les avis des savants', 0),
    (223, N'L''Ijma'' et le Qiyas', 0),
    (223, N'La coutume et la raison seule', 0);

-- Q224 (fiqh/avance) : bonne réponse = Le consensus des savants

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (224, N'L''avis d''un seul savant', 0),
    (224, N'L''analogie juridique', 0),
    (224, N'Le décret d''un souverain', 0),
    (224, N'Le consensus des savants', 1);

-- Q225 (fiqh/avance) : bonne réponse = L'analogie juridique

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (225, N'Le pèlerinage', 0),
    (225, N'Le jeûne surérogatoire', 0),
    (225, N'L''analogie juridique', 1),
    (225, N'Le consensus des savants', 0);

-- Q226 (sira/debutant) : bonne réponse = La Mecque

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (226, N'Médine', 0),
    (226, N'Jérusalem', 0),
    (226, N'La Mecque', 1),
    (226, N'Taïf', 0);

-- Q227 (sira/debutant) : bonne réponse = L'Année de l'Éléphant (Am al-Fil)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (227, N'L''Année de l''Éléphant (Am al-Fil)', 1),
    (227, N'L''Année de la Tristesse', 0),
    (227, N'L''Année de la Conquête', 0),
    (227, N'L''Année des Ambassades', 0);

-- Q228 (sira/debutant) : bonne réponse = Abdallah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (228, N'Abdul-Muttalib', 0),
    (228, N'Abdallah', 1),
    (228, N'Abu Talib', 0),
    (228, N'Hamza', 0);

-- Q229 (sira/debutant) : bonne réponse = Amina bint Wahb

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (229, N'Fatima', 0),
    (229, N'Halima Sa''diyyah', 0),
    (229, N'Amina bint Wahb', 1),
    (229, N'Khadija', 0);

-- Q230 (sira/debutant) : bonne réponse = Abdul-Muttalib

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (230, N'Abu Lahab', 0),
    (230, N'Abdul-Muttalib', 1),
    (230, N'Al-Abbas', 0),
    (230, N'Abu Talib', 0);

-- Q231 (sira/debutant) : bonne réponse = Abu Talib

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (231, N'Abu Lahab', 0),
    (231, N'Hamza', 0),
    (231, N'Al-Abbas', 0),
    (231, N'Abu Talib', 1);

-- Q232 (sira/debutant) : bonne réponse = Halima Sa'diyyah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (232, N'Amina', 0),
    (232, N'Barakah (Umm Ayman)', 0),
    (232, N'Halima Sa''diyyah', 1),
    (232, N'Shima', 0);

-- Q233 (sira/debutant) : bonne réponse = Al-Amin (le digne de confiance)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (233, N'As-Siddiq', 0),
    (233, N'Al-Amin (le digne de confiance)', 1),
    (233, N'Al-Farouq', 0),
    (233, N'Saïf Allah', 0);

-- Q234 (sira/debutant) : bonne réponse = Khadija bint Khuwaylid

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (234, N'Aïcha', 0),
    (234, N'Khadija bint Khuwaylid', 1),
    (234, N'Sawda', 0),
    (234, N'Hafsa', 0);

-- Q235 (sira/debutant) : bonne réponse = 40 ans

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (235, N'25 ans', 0),
    (235, N'40 ans', 1),
    (235, N'30 ans', 0),
    (235, N'63 ans', 0);

-- Q236 (sira/debutant) : bonne réponse = Jibril (Gabriel)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (236, N'Jibril (Gabriel)', 1),
    (236, N'Mikail', 0),
    (236, N'Israfil', 0),
    (236, N'Azrail', 0);

-- Q237 (sira/debutant) : bonne réponse = Iqra' ! (Lis !)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (237, N'Qul ! (Dis !)', 0),
    (237, N'Ibla'' !', 0),
    (237, N'Iqra'' ! (Lis !)', 1),
    (237, N'Qum ! (Lève-toi !)', 0);

-- Q238 (sira/debutant) : bonne réponse = Abu Bakr As-Siddiq

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (238, N'Uthman ibn Affan', 0),
    (238, N'Ali ibn Abi Talib', 0),
    (238, N'Abu Bakr As-Siddiq', 1),
    (238, N'Omar ibn al-Khattab', 0);

-- Q239 (sira/debutant) : bonne réponse = Ali ibn Abi Talib

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (239, N'Ibn Abbas', 0),
    (239, N'Ibn Omar', 0),
    (239, N'Zaïd ibn Harithah', 0),
    (239, N'Ali ibn Abi Talib', 1);

-- Q240 (sira/debutant) : bonne réponse = Bilal ibn Rabah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (240, N'Suhayb ar-Rumi', 0),
    (240, N'Ammar ibn Yasir', 0),
    (240, N'Salman al-Farisi', 0),
    (240, N'Bilal ibn Rabah', 1);

-- Q241 (sira/debutant) : bonne réponse = En Abyssinie (Habasha)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (241, N'À Taïf', 0),
    (241, N'Au Yémen', 0),
    (241, N'À Médine', 0),
    (241, N'En Abyssinie (Habasha)', 1);

-- Q242 (sira/debutant) : bonne réponse = Le Négus (An-Najashi)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (242, N'Chosroès', 0),
    (242, N'Héraclius', 0),
    (242, N'Le Négus (An-Najashi)', 1),
    (242, N'Muqawqis', 0);

-- Q243 (sira/debutant) : bonne réponse = L'Année de la Tristesse ('Am al-Huzn)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (243, N'L''Année du Boycott', 0),
    (243, N'L''Année de la Tristesse (''Am al-Huzn)', 1),
    (243, N'L''Année de l''Éléphant', 0),
    (243, N'L''Année de l''Hégire', 0);

-- Q244 (sira/debutant) : bonne réponse = Al-Isra wa al-Mi'raj

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (244, N'Al-Isra wa al-Mi''raj', 1),
    (244, N'Al-Hijrah', 0),
    (244, N'Al-Fath', 0),
    (244, N'Al-Hudaybiyyah', 0);

-- Q245 (sira/debutant) : bonne réponse = Yathrib (Médine)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (245, N'Yathrib (Médine)', 1),
    (245, N'Taïf', 0),
    (245, N'Sanaa', 0),
    (245, N'La Mecque', 0);

-- Q246 (sira/debutant) : bonne réponse = L'Hégire (Al-Hijrah)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (246, N'L''Isra', 0),
    (246, N'La Umrah', 0),
    (246, N'Le Hajj', 0),
    (246, N'L''Hégire (Al-Hijrah)', 1);

-- Q247 (sira/debutant) : bonne réponse = Abu Bakr As-Siddiq

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (247, N'Omar ibn al-Khattab', 0),
    (247, N'Abu Bakr As-Siddiq', 1),
    (247, N'Ali ibn Abi Talib', 0),
    (247, N'Uthman ibn Affan', 0);

-- Q248 (sira/debutant) : bonne réponse = Les Ansar (les Auxiliaires)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (248, N'Les Ansar (les Auxiliaires)', 1),
    (248, N'Les Muhajirun (les Émigrés)', 0),
    (248, N'Les Quraysh', 0),
    (248, N'Les Thaqif', 0);

-- Q249 (sira/debutant) : bonne réponse = Les Muhajirun (les Émigrés)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (249, N'Les Muhajirun (les Émigrés)', 1),
    (249, N'Les Munafiqun', 0),
    (249, N'Les Ansar', 0),
    (249, N'Les Aws', 0);

-- Q250 (sira/debutant) : bonne réponse = La bataille de Badr

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (250, N'La bataille du Khandaq', 0),
    (250, N'La bataille de Badr', 1),
    (250, N'La bataille d''Uhud', 0),
    (250, N'La bataille de Hunayn', 0);

-- Q251 (sira/intermediaire) : bonne réponse = La bataille d'Uhud

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (251, N'La bataille d''Uhud', 1),
    (251, N'La bataille de Badr', 0),
    (251, N'La bataille de Khaybar', 0),
    (251, N'La bataille de Tabuk', 0);

-- Q252 (sira/intermediaire) : bonne réponse = Salman al-Farisi

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (252, N'Khalid ibn al-Walid', 0),
    (252, N'Abu Dharr', 0),
    (252, N'Bilal ibn Rabah', 0),
    (252, N'Salman al-Farisi', 1);

-- Q253 (sira/intermediaire) : bonne réponse = Le traité d'Al-Hudaybiyyah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (253, N'Le serment d''al-Aqaba', 0),
    (253, N'Le traité d''Al-Hudaybiyyah', 1),
    (253, N'Le pacte de Najran', 0),
    (253, N'La constitution de Médine', 0);

-- Q254 (sira/intermediaire) : bonne réponse = L'an 8

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (254, N'L''an 8', 1),
    (254, N'L''an 2', 0),
    (254, N'L''an 10', 0),
    (254, N'L''an 5', 0);

-- Q255 (sira/intermediaire) : bonne réponse = 63 ans

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (255, N'65 ans', 0),
    (255, N'70 ans', 0),
    (255, N'60 ans', 0),
    (255, N'63 ans', 1);

-- Q256 (sira/intermediaire) : bonne réponse = Les Banu Hashim

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (256, N'Les Banu Hashim', 1),
    (256, N'Les Banu Makhzum', 0),
    (256, N'Les Banu Umayya', 0),
    (256, N'Les Banu Taym', 0);

-- Q257 (sira/intermediaire) : bonne réponse = 25 ans

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (257, N'40 ans', 0),
    (257, N'25 ans', 1),
    (257, N'20 ans', 0),
    (257, N'30 ans', 0);

-- Q258 (sira/intermediaire) : bonne réponse = Environ 13 ans

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (258, N'Environ 23 ans', 0),
    (258, N'Environ 3 ans', 0),
    (258, N'Environ 10 ans', 0),
    (258, N'Environ 13 ans', 1);

-- Q259 (sira/intermediaire) : bonne réponse = Environ 10 ans

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (259, N'Environ 5 ans', 0),
    (259, N'Environ 23 ans', 0),
    (259, N'Environ 13 ans', 0),
    (259, N'Environ 10 ans', 1);

-- Q260 (sira/intermediaire) : bonne réponse = Ibrahim

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (260, N'Abdallah', 0),
    (260, N'Al-Hasan', 0),
    (260, N'Ibrahim', 1),
    (260, N'Qasim', 0);

-- Q261 (sira/intermediaire) : bonne réponse = 4

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (261, N'2', 0),
    (261, N'3', 0),
    (261, N'4', 1),
    (261, N'5', 0);

-- Q262 (sira/intermediaire) : bonne réponse = Fatima az-Zahra

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (262, N'Fatima az-Zahra', 1),
    (262, N'Zaynab', 0),
    (262, N'Umm Kulthum', 0),
    (262, N'Ruqayya', 0);

-- Q263 (sira/intermediaire) : bonne réponse = Uthman ibn Affan

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (263, N'Uthman ibn Affan', 1),
    (263, N'Abu Bakr', 0),
    (263, N'Ali ibn Abi Talib', 0),
    (263, N'Omar ibn al-Khattab', 0);

-- Q264 (sira/intermediaire) : bonne réponse = Sumayya bint Khayyat

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (264, N'Khadija', 0),
    (264, N'Sumayya bint Khayyat', 1),
    (264, N'Asma bint Abi Bakr', 0),
    (264, N'Fatima', 0);

-- Q265 (sira/intermediaire) : bonne réponse = Hamza

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (265, N'Hamza', 1),
    (265, N'Abu Talib', 0),
    (265, N'Abu Lahab', 0),
    (265, N'Al-Abbas', 0);

-- Q266 (sira/intermediaire) : bonne réponse = Abu Lahab

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (266, N'Hamza', 0),
    (266, N'Al-Abbas', 0),
    (266, N'Abu Talib', 0),
    (266, N'Abu Lahab', 1);

-- Q267 (sira/intermediaire) : bonne réponse = Shi'b Abi Talib

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (267, N'Thawr', 0),
    (267, N'Hira', 0),
    (267, N'Shi''b Abi Talib', 1),
    (267, N'Dar al-Arqam', 0);

-- Q268 (sira/intermediaire) : bonne réponse = Dar al-Arqam

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (268, N'Dar Khadija', 0),
    (268, N'Dar an-Nadwa', 0),
    (268, N'Dar al-Arqam', 1),
    (268, N'Dar Abi Bakr', 0);

-- Q269 (sira/intermediaire) : bonne réponse = Taïf

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (269, N'Yathrib', 0),
    (269, N'Sanaa', 0),
    (269, N'Damas', 0),
    (269, N'Taïf', 1);

-- Q270 (sira/intermediaire) : bonne réponse = La mosquée de Quba

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (270, N'La mosquée d''Al-Qiblatayn', 0),
    (270, N'La mosquée de Quba', 1),
    (270, N'La mosquée al-Haram', 0),
    (270, N'La mosquée al-Aqsa', 0);

-- Q271 (sira/intermediaire) : bonne réponse = Jérusalem (Bayt al-Maqdis)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (271, N'Jérusalem (Bayt al-Maqdis)', 1),
    (271, N'Taïf', 0),
    (271, N'Médine', 0),
    (271, N'Le Yémen', 0);

-- Q272 (sira/intermediaire) : bonne réponse = Al-Mu'akhat

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (272, N'Sulh al-Hudaybiyyah', 0),
    (272, N'Al-Mu''akhat', 1),
    (272, N'Bay''at ar-Ridwan', 0),
    (272, N'Al-Hilf', 0);

-- Q273 (sira/intermediaire) : bonne réponse = Environ 313

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (273, N'Environ 3000', 0),
    (273, N'Environ 313', 1),
    (273, N'Environ 1000', 0),
    (273, N'Environ 100', 0);

-- Q274 (sira/intermediaire) : bonne réponse = L'an 3

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (274, N'L''an 3', 1),
    (274, N'L''an 5', 0),
    (274, N'L''an 7', 0),
    (274, N'L''an 1', 0);

-- Q275 (sira/intermediaire) : bonne réponse = La bataille du Khandaq

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (275, N'La bataille de Hunayn', 0),
    (275, N'La bataille de Badr', 0),
    (275, N'La bataille d''Uhud', 0),
    (275, N'La bataille du Khandaq', 1);

-- Q276 (sira/avance) : bonne réponse = Khaybar

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (276, N'Hunayn', 0),
    (276, N'Badr', 0),
    (276, N'Khaybar', 1),
    (276, N'Tabuk', 0);

-- Q277 (sira/avance) : bonne réponse = Khalid ibn al-Walid

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (277, N'Amr ibn al-As', 0),
    (277, N'Sa''d ibn Abi Waqqas', 0),
    (277, N'Zubayr ibn al-Awwam', 0),
    (277, N'Khalid ibn al-Walid', 1);

-- Q278 (sira/avance) : bonne réponse = Hunayn

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (278, N'Hunayn', 1),
    (278, N'Tabuk', 0),
    (278, N'Badr', 0),
    (278, N'Uhud', 0);

-- Q279 (sira/avance) : bonne réponse = Tabuk

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (279, N'Hunayn', 0),
    (279, N'Tabuk', 1),
    (279, N'Khaybar', 0),
    (279, N'Mu''ta', 0);

-- Q280 (sira/avance) : bonne réponse = L'an 10

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (280, N'L''an 11', 0),
    (280, N'L''an 10', 1),
    (280, N'L''an 8', 0),
    (280, N'L''an 9', 0);

-- Q281 (sira/avance) : bonne réponse = Arafat

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (281, N'Al-Aqaba', 0),
    (281, N'La mosquée de Quba', 0),
    (281, N'La grotte de Hira', 0),
    (281, N'Arafat', 1);

-- Q282 (sira/avance) : bonne réponse = Abu Bakr As-Siddiq

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (282, N'Ali ibn Abi Talib', 0),
    (282, N'Omar ibn al-Khattab', 0),
    (282, N'Uthman ibn Affan', 0),
    (282, N'Abu Bakr As-Siddiq', 1);

-- Q283 (sira/avance) : bonne réponse = Al-Qaswa

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (283, N'Al-Buraq', 0),
    (283, N'Duldul', 0),
    (283, N'Ya''fur', 0),
    (283, N'Al-Qaswa', 1);

-- Q284 (sira/avance) : bonne réponse = Al-Buraq

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (284, N'Ya''fur', 0),
    (284, N'Duldul', 0),
    (284, N'Al-Qaswa', 0),
    (284, N'Al-Buraq', 1);

-- Q285 (sira/avance) : bonne réponse = Mus'ab ibn Umayr

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (285, N'Mus''ab ibn Umayr', 1),
    (285, N'Salman al-Farisi', 0),
    (285, N'Bilal ibn Rabah', 0),
    (285, N'Khalid ibn al-Walid', 0);

-- Q286 (sira/avance) : bonne réponse = Abu Ubayda ibn al-Jarrah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (286, N'Zubayr ibn al-Awwam', 0),
    (286, N'Abdurrahman ibn Awf', 0),
    (286, N'Abu Ubayda ibn al-Jarrah', 1),
    (286, N'Talha ibn Ubaydillah', 0);

-- Q287 (sira/avance) : bonne réponse = 10

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (287, N'12', 0),
    (287, N'7', 0),
    (287, N'4', 0),
    (287, N'10', 1);

-- Q288 (sira/avance) : bonne réponse = Omar ibn al-Khattab

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (288, N'Omar ibn al-Khattab', 1),
    (288, N'Ali ibn Abi Talib', 0),
    (288, N'Abu Bakr', 0),
    (288, N'Uthman ibn Affan', 0);

-- Q289 (sira/avance) : bonne réponse = Sawda bint Zam'a

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (289, N'Aïcha', 0),
    (289, N'Sawda bint Zam''a', 1),
    (289, N'Zaynab bint Jahsh', 0),
    (289, N'Hafsa', 0);

-- Q290 (sira/avance) : bonne réponse = Aïcha

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (290, N'Sawda', 0),
    (290, N'Aïcha', 1),
    (290, N'Hafsa', 0),
    (290, N'Umm Salama', 0);

-- Q291 (sira/avance) : bonne réponse = Hafsa

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (291, N'Aïcha', 0),
    (291, N'Hafsa', 1),
    (291, N'Zaynab bint Jahsh', 0),
    (291, N'Umm Habiba', 0);

-- Q292 (sira/avance) : bonne réponse = Uthman ibn Affan

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (292, N'Abu Bakr', 0),
    (292, N'Uthman ibn Affan', 1),
    (292, N'Zubayr ibn al-Awwam', 0),
    (292, N'Ja''far ibn Abi Talib', 0);

-- Q293 (sira/avance) : bonne réponse = Ja'far ibn Abi Talib

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (293, N'Abu Bakr', 0),
    (293, N'Ja''far ibn Abi Talib', 1),
    (293, N'Uthman ibn Affan', 0),
    (293, N'Ali ibn Abi Talib', 0);

-- Q294 (sira/avance) : bonne réponse = Bay'at ar-Ridwan

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (294, N'Bay''at as-Saqifa', 0),
    (294, N'Bay''at al-Fath', 0),
    (294, N'Bay''at ar-Ridwan', 1),
    (294, N'Bay''at al-Aqaba', 0);

-- Q295 (sira/avance) : bonne réponse = Bilal ibn Rabah

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (295, N'Bilal ibn Rabah', 1),
    (295, N'Abu Bakr', 0),
    (295, N'Khalid ibn al-Walid', 0),
    (295, N'Omar ibn al-Khattab', 0);

-- Q296 (sira/avance) : bonne réponse = Chosroès (Kisra)

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (296, N'Al-Muqawqis', 0),
    (296, N'An-Najashi', 0),
    (296, N'Héraclius', 0),
    (296, N'Chosroès (Kisra)', 1);

-- Q297 (sira/avance) : bonne réponse = Al-Muqawqis

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (297, N'Al-Muqawqis', 1),
    (297, N'Héraclius', 0),
    (297, N'An-Najashi', 0),
    (297, N'Chosroès', 0);

-- Q298 (sira/avance) : bonne réponse = Aïcha

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (298, N'Sawda', 0),
    (298, N'Aïcha', 1),
    (298, N'Umm Salama', 0),
    (298, N'Hafsa', 0);

-- Q299 (sira/avance) : bonne réponse = Ali ibn Abi Talib

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (299, N'Abu Bakr', 0),
    (299, N'Ali ibn Abi Talib', 1),
    (299, N'Zubayr ibn al-Awwam', 0),
    (299, N'Omar ibn al-Khattab', 0);

-- Q300 (sira/avance) : bonne réponse = Les Aws et les Khazraj

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (300, N'Les Banu Qurayza et les Banu Nadir', 0),
    (300, N'Les Aws et les Khazraj', 1),
    (300, N'Les Quraysh et les Thaqif', 0),
    (300, N'Les Ghatafan et les Hawazin', 0);


-- ======== CORAN – MÉDITER et TAJWID : 60 questions ========
INSERT INTO dbo.questions (id, categorie, niveau, enonce) VALUES
    (301, N'coran_mediter', N'debutant', N'Que signifie le « Tadabbur » du Coran ?'),
    (302, N'coran_mediter', N'debutant', N'Que nous enseigne « Avec la difficulté vient la facilité » (sourate Ash-Sharh) ?'),
    (303, N'coran_mediter', N'debutant', N'Selon la sourate Ar-Ra''d, qu''est-ce qui apaise les cœurs ?'),
    (304, N'coran_mediter', N'debutant', N'Quel est le thème central de la sourate Al-Ikhlas ?'),
    (305, N'coran_mediter', N'debutant', N'Que signifie « Iyyaka na''budu wa iyyaka nasta''in » (Al-Fatiha) ?'),
    (306, N'coran_mediter', N'debutant', N'Que nous enseigne le verset « Allah n''impose à aucune âme une charge supérieure à sa capacité » (Al-Baqarah) ?'),
    (307, N'coran_mediter', N'debutant', N'Selon la sourate Al-Hujurat, qui est le plus noble auprès d''Allah ?'),
    (308, N'coran_mediter', N'debutant', N'Après l''ordre d''adorer Allah seul, quel comportement la sourate Al-Isra recommande-t-elle ?'),
    (309, N'coran_mediter', N'debutant', N'Quel message la sourate Al-Asr rappelle-t-elle à l''humanité ?'),
    (310, N'coran_mediter', N'debutant', N'Que demande Allah en disant « Souvenez-vous de Moi, Je me souviendrai de vous » ?'),
    (311, N'coran_mediter', N'intermediaire', N'Selon la sourate At-Talaq, quelle est la promesse faite à celui qui craint Allah (taqwa) ?'),
    (312, N'coran_mediter', N'intermediaire', N'Combien de fois la phrase « Avec la difficulté vient une facilité » apparaît-elle dans la sourate Ash-Sharh ?'),
    (313, N'coran_mediter', N'intermediaire', N'Quel message le verset de la sourate Az-Zumar adressé aux serviteurs qui ont commis des excès transmet-il ?'),
    (314, N'coran_mediter', N'intermediaire', N'Quel est le premier conseil de Luqman à son fils dans le Coran ?'),
    (315, N'coran_mediter', N'intermediaire', N'Dans quelle sourate se trouve le verset de la Lumière (« Allah est la lumière des cieux et de la terre ») ?'),
    (316, N'coran_mediter', N'intermediaire', N'Selon la sourate Al-Kahf, qu''est-ce qui est meilleur auprès d''Allah en récompense ?'),
    (317, N'coran_mediter', N'intermediaire', N'Comment la sourate Al-Hadid décrit-elle la vie présente ?'),
    (318, N'coran_mediter', N'intermediaire', N'Selon la sourate An-Nahl, comment faut-il appeler à la voie d''Allah ?'),
    (319, N'coran_mediter', N'intermediaire', N'Que recommande la sourate Al-Baqarah pour chercher secours auprès d''Allah ?'),
    (320, N'coran_mediter', N'intermediaire', N'Que demande Allah dans la sourate Al-A''raf lorsque le Coran est récité ?'),
    (321, N'coran_mediter', N'avance', N'Quel argument la sourate An-Nisa avance-t-elle sur l''origine du Coran ?'),
    (322, N'coran_mediter', N'avance', N'Que dit la sourate Al-Hashr à propos de l''effet du Coran sur une montagne ?'),
    (323, N'coran_mediter', N'avance', N'Vers quoi le Coran guide-t-il selon la sourate Al-Isra ?'),
    (324, N'coran_mediter', N'avance', N'Selon la sourate Al-Ankabut, de quoi la prière préserve-t-elle ?'),
    (325, N'coran_mediter', N'avance', N'Quel principe énonce la sourate Ar-Ra''d au sujet du changement d''un peuple ?'),
    (326, N'coran_mediter', N'avance', N'Combien de fois le verset « Lequel des bienfaits de votre Seigneur nierez-vous ? » est-il répété dans la sourate Ar-Rahman ?'),
    (327, N'coran_mediter', N'avance', N'Quelle sourate se termine par « À vous votre religion, et à moi ma religion » ?'),
    (328, N'coran_mediter', N'avance', N'Pour qui le Coran est-il « un guide », selon les premiers versets de la sourate Al-Baqarah ?'),
    (329, N'coran_mediter', N'avance', N'Quel est le but de la révélation du Coran évoqué dans la sourate Sad : « Un Livre béni que Nous t''avons révélé afin que… » ?'),
    (330, N'coran_mediter', N'avance', N'Selon la sourate Al-Anfal, que ressentent les croyants quand Allah est mentionné ?'),
    (331, N'coran_tajwid', N'debutant', N'Que signifie le Tajwid ?'),
    (332, N'coran_tajwid', N'debutant', N'Combien de temps (harakat) dure le madd naturel (madd asli) ?'),
    (333, N'coran_tajwid', N'debutant', N'Quelle règle s''applique à un noun sakin ou tanwin suivi de la lettre « ب » ?'),
    (334, N'coran_tajwid', N'debutant', N'Combien y a-t-il de lettres de l''izhar halqi (lettres de la gorge) ?'),
    (335, N'coran_tajwid', N'debutant', N'Quelles sont les lettres de la qalqala ?'),
    (336, N'coran_tajwid', N'debutant', N'Quelles lettres déclenchent l''idgham après un noun sakin ou un tanwin ?'),
    (337, N'coran_tajwid', N'debutant', N'Quelle règle s''applique à un mim sakin suivi de « ب » ?'),
    (338, N'coran_tajwid', N'debutant', N'Que signifie la ghunna ?'),
    (339, N'coran_tajwid', N'debutant', N'Laquelle de ces lettres sort des lèvres ?'),
    (340, N'coran_tajwid', N'debutant', N'Qu''est-ce que le tanwin ?'),
    (341, N'coran_tajwid', N'intermediaire', N'Combien de temps dure la ghunna (nasalisation) ?'),
    (342, N'coran_tajwid', N'intermediaire', N'Combien de lettres compte l''ikhfa haqiqi ?'),
    (343, N'coran_tajwid', N'intermediaire', N'Quelles lettres relèvent de l''idgham avec ghunna ?'),
    (344, N'coran_tajwid', N'intermediaire', N'Quelles lettres relèvent de l''idgham sans ghunna ?'),
    (345, N'coran_tajwid', N'intermediaire', N'Dans le madd muttasil, où se trouve la hamza par rapport à la lettre de madd ?'),
    (346, N'coran_tajwid', N'intermediaire', N'Dans le madd munfasil, où se trouve la hamza ?'),
    (347, N'coran_tajwid', N'intermediaire', N'Combien de temps dure le madd lazim ?'),
    (348, N'coran_tajwid', N'intermediaire', N'Quelles sont les lettres de madd ?'),
    (349, N'coran_tajwid', N'intermediaire', N'En quoi consiste la qalqala ?'),
    (350, N'coran_tajwid', N'intermediaire', N'Combien y a-t-il de lettres d''isti''la (lettres lourdes) ?'),
    (351, N'coran_tajwid', N'avance', N'Qu''est-ce que l''idgham mutamathilayn ?'),
    (352, N'coran_tajwid', N'avance', N'Les lettres « ق » et « ك » (comme dans « نخلقكم ») relèvent de quel type d''idgham ?'),
    (353, N'coran_tajwid', N'avance', N'Combien de temps peut durer le madd ''arid lissukun ?'),
    (354, N'coran_tajwid', N'avance', N'Quand le madd liin apparaît-il ?'),
    (355, N'coran_tajwid', N'avance', N'Combien de temps dure le madd badal (par exemple dans « آمنوا ») dans la lecture de Hafs ?'),
    (356, N'coran_tajwid', N'avance', N'Quand prolonge-t-on le « ه » du pronom (silat ha'' ad-damir) de 2 temps ?'),
    (357, N'coran_tajwid', N'avance', N'Combien y a-t-il de lettres solaires (chamsiyya) ?'),
    (358, N'coran_tajwid', N'avance', N'Le « ر » est généralement lourd (tafkhim) lorsqu''il porte…'),
    (359, N'coran_tajwid', N'avance', N'Que signifie le waqf ?'),
    (360, N'coran_tajwid', N'avance', N'Quelles lettres portent la ghunna mushaddada (nasalisation renforcée) ?');

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (301, N'Réfléchir en profondeur au sens des versets', 1),
    (301, N'Copier le Mushaf', 0),
    (301, N'Réciter très vite', 0),
    (301, N'Apprendre les sourates par cœur sans les comprendre', 0),
    (302, N'Qu''il faut éviter tout effort', 0),
    (302, N'Que la difficulté ne finit jamais', 0),
    (302, N'Qu''une épreuve est suivie d''un soulagement', 1),
    (302, N'Que la facilité vient sans épreuve', 0),
    (303, N'Le rappel (dhikr) d''Allah', 1),
    (303, N'Les divertissements', 0),
    (303, N'La richesse', 0),
    (303, N'Le pouvoir', 0),
    (304, N'Les règles de l''héritage', 0),
    (304, N'L''unicité d''Allah', 1),
    (304, N'L''histoire des prophètes', 0),
    (304, N'Le jeûne du Ramadan', 0),
    (305, N'C''est Toi seul que nous adorons et Toi seul dont nous implorons l''aide', 1),
    (305, N'Louange à Allah, Seigneur des mondes', 0),
    (305, N'Maître du Jour de la rétribution', 0),
    (305, N'Guide-nous vers le droit chemin', 0),
    (306, N'Qu''il faut renoncer à toute difficulté', 0),
    (306, N'Allah ne nous demande que ce que nous pouvons supporter', 1),
    (306, N'Que seuls les riches sont éprouvés', 0),
    (306, N'Que les épreuves n''ont aucun sens', 0),
    (307, N'Le plus pieux', 1),
    (307, N'Le plus savant des généalogies', 0),
    (307, N'Le plus puissant', 0),
    (307, N'Le plus riche', 0),
    (308, N'Le commerce', 0),
    (308, N'La bienfaisance envers les parents', 1),
    (308, N'Le voyage', 0),
    (308, N'L''isolement', 0),
    (309, N'L''homme est en perte, sauf ceux qui croient et accomplissent de bonnes œuvres', 1),
    (309, N'Le temps n''a pas d''importance', 0),
    (309, N'Tous les hommes sont égaux en richesse', 0),
    (309, N'Seuls les savants seront sauvés', 0),
    (310, N'L''invoquer et le mentionner souvent', 1),
    (310, N'Ne parler à personne', 0),
    (310, N'Voyager pour la science', 0),
    (310, N'Jeûner chaque jour', 0),
    (311, N'Une issue et une subsistance d''où il ne s''y attend pas', 1),
    (311, N'Un pouvoir sur les autres', 0),
    (311, N'Une longue vie assurée', 0),
    (311, N'Une vie sans épreuve', 0),
    (312, N'1 fois', 0),
    (312, N'4 fois', 0),
    (312, N'2 fois', 1),
    (312, N'3 fois', 0),
    (313, N'Chacun doit porter seul son péché', 0),
    (313, N'Le repentir est inutile', 0),
    (313, N'Ne désespérez pas de la miséricorde d''Allah', 1),
    (313, N'Le pardon est réservé aux prophètes', 0),
    (314, N'Étudier la médecine', 0),
    (314, N'Voyager pour s''enrichir', 0),
    (314, N'Ne pas associer d''autres divinités à Allah', 1),
    (314, N'Éviter les gens', 0),
    (315, N'An-Nur', 1),
    (315, N'Al-Hadid', 0),
    (315, N'Al-Kahf', 0),
    (315, N'Ya-Sin', 0),
    (316, N'Le pouvoir', 0),
    (316, N'La renommée', 0),
    (316, N'Les bonnes œuvres durables', 1),
    (316, N'Les biens et les enfants', 0),
    (317, N'Un simple rêve', 0),
    (317, N'Un jeu, un amusement et une jouissance trompeuse', 1),
    (317, N'Une éternité heureuse', 0),
    (317, N'Un exil sans fin', 0),
    (318, N'Par la sagesse et la bonne exhortation', 1),
    (318, N'Par le silence', 0),
    (318, N'Par la contrainte', 0),
    (318, N'Par la moquerie', 0),
    (319, N'La patience et la prière', 1),
    (319, N'Les voyages et le commerce', 0),
    (319, N'Les richesses et les armes', 0),
    (319, N'La solitude et le silence', 0),
    (320, N'Poursuivre ses activités', 0),
    (320, N'Le traduire immédiatement', 0),
    (320, N'L''écouter attentivement et garder le silence', 1),
    (320, N'Le réciter plus fort', 0),
    (321, N'Il a été écrit par plusieurs auteurs', 0),
    (321, N'Il ressemble aux autres livres', 0),
    (321, N'S''il venait d''un autre qu''Allah, on y trouverait beaucoup de contradictions', 1),
    (321, N'Il a été composé en une nuit', 0),
    (322, N'Elle s''humilierait et se fendrait par crainte d''Allah', 1),
    (322, N'Elle disparaîtrait', 0),
    (322, N'Elle deviendrait un jardin', 0),
    (322, N'Elle parlerait aux hommes', 0),
    (323, N'Vers ce qui est le plus droit', 1),
    (323, N'Vers le plus rapide', 0),
    (323, N'Vers le plus facile', 0),
    (323, N'Vers le plus lointain', 0),
    (324, N'De la turpitude et du blâmable', 1),
    (324, N'De la maladie', 0),
    (324, N'De la pauvreté', 0),
    (324, N'De la fatigue', 0),
    (325, N'Le destin ne dépend de personne', 0),
    (325, N'Allah ne change pas l''état d''un peuple tant qu''il n''a pas changé ce qui est en lui-même', 1),
    (325, N'Seuls les dirigeants peuvent changer un peuple', 0),
    (325, N'Allah change tout sans condition', 0),
    (326, N'7 fois', 0),
    (326, N'40 fois', 0),
    (326, N'31 fois', 1),
    (326, N'114 fois', 0),
    (327, N'Al-Kafirun', 1),
    (327, N'An-Nasr', 0),
    (327, N'Al-Masad', 0),
    (327, N'Al-Ikhlas', 0),
    (328, N'Pour les pieux (muttaqin)', 1),
    (328, N'Pour les rois', 0),
    (328, N'Pour les savants uniquement', 0),
    (328, N'Pour les seuls Arabes', 0),
    (329, N'Qu''ils le vendent', 0),
    (329, N'Qu''ils méditent sur ses versets', 1),
    (329, N'Qu''ils le gardent fermé', 0),
    (329, N'Qu''ils l''oublient', 0),
    (330, N'Ils s''endorment', 0),
    (330, N'Ils restent indifférents', 0),
    (330, N'Leurs cœurs frémissent', 1),
    (330, N'Ils s''éloignent', 0),
    (331, N'Écrire le Coran en calligraphie', 0),
    (331, N'Réciter le Coran en donnant à chaque lettre son droit', 1),
    (331, N'Mémoriser le Coran', 0),
    (331, N'Traduire le Coran', 0),
    (332, N'2 temps', 1),
    (332, N'6 temps', 0),
    (332, N'1 temps', 0),
    (332, N'4 temps', 0),
    (333, N'Izhar', 0),
    (333, N'Qalqala', 0),
    (333, N'Idgham', 0),
    (333, N'Iqlab', 1),
    (334, N'6', 1),
    (334, N'15', 0),
    (334, N'4', 0),
    (334, N'10', 0),
    (335, N'خ ص ض غ ط ق ظ', 0),
    (335, N'ا و ي', 0),
    (335, N'ق ط ب ج د', 1),
    (335, N'ن م', 0),
    (336, N'ي ر م ل و ن', 1),
    (336, N'ق ط ب ج د', 0),
    (336, N'ء ه ع ح غ خ', 0),
    (336, N'ا و ي', 0),
    (337, N'Ikhfa chafawi', 1),
    (337, N'Idgham chafawi', 0),
    (337, N'Iqlab', 0),
    (337, N'Izhar chafawi', 0),
    (338, N'Un son nasal produit par le nez', 1),
    (338, N'Un arrêt de la voix', 0),
    (338, N'Un allongement de 6 temps', 0),
    (338, N'Une lettre lourde', 0),
    (339, N'ك', 0),
    (339, N'ق', 0),
    (339, N'ع', 0),
    (339, N'ب', 1),
    (340, N'Une lettre de madd', 0),
    (340, N'Un noun sakin prononcé à la fin d''un nom, sans être écrit comme lettre', 1),
    (340, N'Un signe de doublement', 0),
    (340, N'Un signe d''arrêt', 0),
    (341, N'2 temps', 1),
    (341, N'4 temps', 0),
    (341, N'6 temps', 0),
    (341, N'1 temps', 0),
    (342, N'7', 0),
    (342, N'15', 1),
    (342, N'14', 0),
    (342, N'6', 0),
    (343, N'ل ر', 0),
    (343, N'ق ط ب ج د', 0),
    (343, N'ء ه ع ح غ خ', 0),
    (343, N'ي ن م و', 1),
    (344, N'ل ر', 1),
    (344, N'ق ط ب ج د', 0),
    (344, N'ي ن م و', 0),
    (344, N'ب', 0),
    (345, N'Dans le mot suivant', 0),
    (345, N'Dans le même mot', 1),
    (345, N'Dans la sourate précédente', 0),
    (345, N'Il n''y a pas de hamza', 0),
    (346, N'Dans le mot suivant', 1),
    (346, N'Dans le même mot', 0),
    (346, N'Avant la lettre de madd', 0),
    (346, N'Il n''y a pas de hamza', 0),
    (347, N'6 temps', 1),
    (347, N'1 temps', 0),
    (347, N'4 temps', 0),
    (347, N'2 temps', 0),
    (348, N'ن م', 0),
    (348, N'ا و ي', 1),
    (348, N'ق ط ب', 0),
    (348, N'ء ه ع', 0),
    (349, N'Un allongement de 6 temps', 0),
    (349, N'Un léger rebond sonore sur la lettre sakin', 1),
    (349, N'Un chuchotement', 0),
    (349, N'Une nasalisation', 0),
    (350, N'10', 0),
    (350, N'7', 1),
    (350, N'14', 0),
    (350, N'5', 0),
    (351, N'La rencontre d''un noun sakin et d''un ba', 0),
    (351, N'La rencontre de deux lettres différentes', 0),
    (351, N'La rencontre de deux lettres identiques, la première sakin et la seconde voyellée', 1),
    (351, N'La rencontre de deux voyelles longues', 0),
    (352, N'Mutaqaribayn', 1),
    (352, N'Mutamathilayn', 0),
    (352, N'Mutajanisayn', 0),
    (352, N'Chamsi', 0),
    (353, N'1 temps', 0),
    (353, N'Seulement 6 temps', 0),
    (353, N'2, 4 ou 6 temps', 1),
    (353, N'Seulement 2 temps', 0),
    (354, N'Sur un noun sakin', 0),
    (354, N'Sur un alif précédé d''une kasra', 0),
    (354, N'Sur un waw ou un ya sakin précédé d''une fatha, lors de l''arrêt', 1),
    (354, N'Sur une hamza voyellée', 0),
    (355, N'8 temps', 0),
    (355, N'4 temps', 0),
    (355, N'2 temps', 1),
    (355, N'6 temps', 0),
    (356, N'Quand il est placé entre deux lettres voyellées', 1),
    (356, N'Quand il est précédé d''une lettre sakin', 0),
    (356, N'Quand on s''arrête dessus', 0),
    (356, N'Jamais', 0),
    (357, N'6', 0),
    (357, N'14', 1),
    (357, N'28', 0),
    (357, N'15', 0),
    (358, N'Une fatha ou une damma', 1),
    (358, N'Une kasra', 0),
    (358, N'Un sukun précédé d''une kasra', 0),
    (358, N'Aucune voyelle jamais', 0),
    (359, N'Allonger une voyelle', 0),
    (359, N'Fusionner deux lettres', 0),
    (359, N'Nasaliser une lettre', 0),
    (359, N'S''arrêter sur un mot en reprenant son souffle', 1),
    (360, N'ق et ك', 0),
    (360, N'ب et ت', 0),
    (360, N'ن et م avec chadda', 1),
    (360, N'ا et و', 0);


-- ======== QUIZ TAWHID (KITÂB AT-TAWHÎD) : 100 QUESTIONS ========

INSERT INTO dbo.questions (id, categorie, niveau, enonce) VALUES
    (1001, N'tawhid_fondements', N'debutant', N'Quel est le but premier pour lequel Allah a créé les djinns et les êtres humains ?'),
    (1002, N'tawhid_fondements', N'debutant', N'Quelle est la mission commune confiée par Allah à tous Ses messagers envoyés aux communautés ?'),
    (1003, N'tawhid_fondements', N'debutant', N'Que désigne le terme ''Tâghût'' dans la théologie du Tawhid ?'),
    (1004, N'tawhid_fondements', N'debutant', N'D''après le hadith de Mu''âdh ibn Jabal, quel est le droit absolu d''Allah sur Ses serviteurs ?'),
    (1005, N'tawhid_fondements', N'debutant', N'Quel est le droit des serviteurs sur Allah s''ils s''acquittent de Son droit (le Tawhid) ?'),
    (1006, N'tawhid_fondements', N'debutant', N'Quelle condition fondamentale est indispensable pour que la croyance en Allah soit valide ?'),
    (1007, N'tawhid_fondements', N'debutant', N'Pourquoi le Prophète ﷺ a-t-il demandé à Mu''âdh de ne pas annoncer immédiatement cette bonne nouvelle aux gens ?'),
    (1008, N'tawhid_fondements', N'debutant', N'Par quoi commence le verset des ''dix droits'' dans la sourate An-Nisâ'' (v. 36) ?'),
    (1009, N'tawhid_fondements', N'debutant', N'Dans la sourate Al-An''âm (v. 151-153), quel est le premier des dix commandements cités ?'),
    (1010, N'tawhid_fondements', N'debutant', N'Quelle est la recommandation majeure mentionnée par Ibn Mas''ûd concernant le testament spirituel du Prophète ﷺ ?'),
    (1011, N'tawhid_fondements', N'debutant', N'Comment le Coran (Sourate Al-An''âm, v. 82) qualifie-t-il l''associationnisme (Shirk) ?'),
    (1012, N'tawhid_fondements', N'debutant', N'D''après le hadith d''Ubâda ibn As-Sâmit, quelle est la récompense de celui qui témoigne sincèrement de la vérité du Tawhid et de la prophétie ?'),
    (1013, N'tawhid_fondements', N'debutant', N'Que nous apprend le hadith d''Itbân ibn Mâlik sur l''Enfer et le Tawhid ?'),
    (1014, N'tawhid_fondements', N'debutant', N'Dans le hadith d''Abu Sa''îd Al-Khudrî, quelle comparaison illustre la lourdeur et la valeur de la formule ''Lâ ilâha illâ Allâh'' ?'),
    (1015, N'tawhid_fondements', N'intermediaire', N'D''après le hadith Qudsî rapporté par Anas, que promet Allah à celui qui se présente devant Lui avec la Terre remplie de péchés sans Lui avoir rien associé ?'),
    (1016, N'tawhid_fondements', N'intermediaire', N'Quelle est la condition indispensable énoncée dans tous ces hadiths pour bénéficier du pardon total des péchés ?'),
    (1017, N'tawhid_fondements', N'intermediaire', N'Quelle vérité théologique concernant Jésus (''Îsâ) fait partie du témoignage de foi mentionné dans le hadith d''Ubâda ?'),
    (1018, N'tawhid_fondements', N'intermediaire', N'Que signifie l''expression ''Sa parole qu''Il a jetée en Maryam'' au sujet du prophète Jésus ?'),
    (1019, N'tawhid_fondements', N'intermediaire', N'Pourquoi la parole ''Lâ ilâha illâ Allâh'' n''est-elle pas suffisante si elle est prononcée par un hypocrite ?'),
    (1020, N'tawhid_fondements', N'intermediaire', N'Quel est le sens de ''Ceux qui ont cru et n''ont pas entaché leur foi d''injustice'' ?'),
    (1021, N'tawhid_fondements', N'intermediaire', N'Quelle est la récompense attribuée à ceux qui réalisent parfaitement le Tawhid ?'),
    (1022, N'tawhid_fondements', N'intermediaire', N'Quelles sont les qualités exceptionnelles attribuées au Prophète Ibrâhîm (Abraham) dans la sourate An-Nahl (v. 120) ?'),
    (1023, N'tawhid_fondements', N'intermediaire', N'Dans le hadith d''Ibn ''Abbâs sur les 70 000 personnes entrant au Paradis sans compte, quelles sont leurs caractéristiques principales ?'),
    (1024, N'tawhid_fondements', N'intermediaire', N'Quel noble Compagnon s''est levé pour demander au Prophète ﷺ de prier Allah afin qu''il fasse partie de ces 70 000 privilégiés ?'),
    (1025, N'tawhid_fondements', N'intermediaire', N'Quelle est la règle coranique concernant le pardon du Shirk (Sourate An-Nisâ'', v. 48) si la personne meurt sans repentir ?'),
    (1026, N'tawhid_fondements', N'intermediaire', N'Quelle invocation le prophète Ibrâhîm (Abraham) a-t-il formulée dans la sourate Ibrâhîm (v. 35) ?'),
    (1027, N'tawhid_fondements', N'intermediaire', N'Quelle est la chose que le Prophète ﷺ craignait le plus pour sa communauté vertueuse ?'),
    (1028, N'tawhid_fondements', N'avance', N'D''après le hadith rapporté par Ibn Mas''ûd dans le Sahîh Al-Bukhârî, quel est le sort de celui qui meurt en invoquant un égal (Nidd) en dehors d''Allah ?'),
    (1029, N'tawhid_fondements', N'avance', N'D''après le hadith de Jâbir ibn ''Abdillâh rapporté par Muslim, quelle est la condition pour entrer au Paradis ?'),
    (1030, N'tawhid_fondements', N'avance', N'Pourquoi la demande de Ruqyah (exorcisme/incantation) est-elle délaissée par ceux qui atteignent la perfection du Tawhid ?'),
    (1031, N'tawhid_fondements', N'avance', N'Selon la sourate Yûsuf (v. 108), quelle est la voie du Prophète ﷺ et de ceux qui le suivent ?'),
    (1032, N'tawhid_fondements', N'avance', N'Lorsque le Prophète ﷺ a envoyé Mu''âdh ibn Jabal au Yémen, par quoi lui a-t-il ordonné de commencer la prédication ?'),
    (1033, N'tawhid_fondements', N'avance', N'Dans quel ordre pédagogique les obligations religieuses doivent-elles être présentées selon ce même hadith de Mu''âdh ?'),
    (1034, N'tawhid_fondements', N'avance', N'Le jour de la bataille de Khaybar, à qui le Prophète ﷺ a-t-il confié l''étendard en annonçant qu''Allah accorderait la victoire par ses mains ?'),
    (1035, N'tawhid_fondements', N'avance', N'Quelle recommandation le Prophète ﷺ a-t-il donnée à ''Ali avant d''engager le combat à Khaybar ?'),
    (1036, N'tawhid_fondements', N'avance', N'Quelle est la valeur immense énoncée par le Prophète ﷺ si une seule personne est guidée par notre intermédiaire ?'),
    (1037, N'tawhid_fondements', N'avance', N'Que dénonce la sourate At-Tawba (v. 31) dans la parole : ''Ils ont pris leurs savants et leurs moines comme des seigneurs en dehors d''Allah'' ?'),
    (1038, N'tawhid_fondements', N'avance', N'Que révèle la parole du prophète Ibrâhîm à son père et son peuple : ''Je désavoue ce que vous adorez, à l''exception de Celui qui m''a créé'' (Az-Zukhruf, v. 26-27) ?'),
    (1039, N'tawhid_fondements', N'avance', N'D''après la sourate Al-Baqara (v. 165), quel est le grand Shirk commis par certains hommes dans le domaine de l''amour ?'),
    (1040, N'tawhid_fondements', N'avance', N'Quel principe fondamental garantit la protection du sang et des biens d''un individu selon le hadith rapporté par Muslim ?'),
    (1041, N'tawhid_adoration', N'debutant', N'Quel est le statut religieux d''immoler un animal en sacrifice pour un saint, un djin ou un ancêtre défunt ?'),
    (1042, N'tawhid_adoration', N'debutant', N'Quelle malédiction est rapportée par ''Ali ibn Abî Tâlib dans le Sahîh Muslim concernant le sacrifice ?'),
    (1043, N'tawhid_adoration', N'debutant', N'Dans le récit emblématique des deux hommes et de la mouche, pourquoi le premier homme est-il entré en Enfer ?'),
    (1044, N'tawhid_adoration', N'debutant', N'Pourquoi le second homme du même récit est-il entré au Paradis ?'),
    (1045, N'tawhid_adoration', N'debutant', N'Un homme ayant fait le vœu d''immoler un chameau à un endroit nommé ''Buwâna'' est venu interroger le Prophète ﷺ. Quelle condition le Prophète a-t-il vérifiée avant d''autoriser le vœu ?'),
    (1046, N'tawhid_adoration', N'debutant', N'Quel est le jugement religieux de vouer un vœu pieux (Nathr) à une créature (saint, tombeau, djin) ?'),
    (1047, N'tawhid_adoration', N'debutant', N'Que doit faire une personne qui a fait le vœu de désobéir à Allah (par exemple rompre les liens familiaux ou commettre un péché) ?'),
    (1048, N'tawhid_adoration', N'debutant', N'Quelle est la règle concernant le fait de chercher refuge (Isti''âdhah) auprès des djinns ou des esprits dans les lieux déserts ?'),
    (1049, N'tawhid_adoration', N'debutant', N'Quelle est la formule prophétique enseignée par Khawla bint Hakîm pour se protéger lorsqu''on fait escale dans un lieu ?'),
    (1050, N'tawhid_adoration', N'debutant', N'Quelle est la différence entre demander de l''aide à une créature vivante et capable, et l''imploration du secours (Istighâthah) auprès d''un mort ou d''un absent ?'),
    (1051, N'tawhid_adoration', N'intermediaire', N'A qui appartient la totalité de l''intercession (Al-Shafâ''ah) selon le verset de la sourate Az-Zumar (v. 44) ?'),
    (1052, N'tawhid_adoration', N'intermediaire', N'Quelles sont les deux conditions obligatoires pour que l''intercession acceptée (Al-Shafâ''ah Al-Muthbatah) ait lieu au Jour Dernier ?'),
    (1053, N'tawhid_adoration', N'intermediaire', N'Quelle fut l''origine historique du tout premier Shirk apparu sur Terre au temps du peuple du prophète Nûh (Noé) ?'),
    (1054, N'tawhid_adoration', N'intermediaire', N'Quel avertissement sévère le Prophète ﷺ a-t-il donné concernant sa propre personne dans le Sahîh Al-Bukhârî ?'),
    (1055, N'tawhid_adoration', N'intermediaire', N'Qu''ont fait les juifs et les chrétiens à l''égard des tombes de leurs prophètes, ce qui leur a valu la malédiction divine ?'),
    (1056, N'tawhid_adoration', N'intermediaire', N'Comment le Prophète ﷺ qualifie-t-il ceux qui construisent des édifices de prière sur la tombe d''un homme pieux et y dessinent des images ?'),
    (1057, N'tawhid_adoration', N'intermediaire', N'Quelle décision fut prise concernant la tombe du Prophète ﷺ pour éviter qu''elle ne devienne une idole adorée ?'),
    (1058, N'tawhid_adoration', N'intermediaire', N'Quelle invocation le Prophète ﷺ répétait-il pour préserver sa tombe après son décès ?'),
    (1059, N'tawhid_adoration', N'intermediaire', N'Qu''a répondu Ali ibn Al-Husayn (Zayn Al-''Âbidîn) à l''homme qu''il a vu s''introduire vers une ouverture près de la tombe du Prophète ﷺ pour y faire des invocations ?'),
    (1060, N'tawhid_adoration', N'intermediaire', N'Quel est le statut d''éclairer les tombes avec des lampes/projecteurs ou d''y sacrifier des animaux ?'),
    (1061, N'tawhid_adoration', N'avance', N'Quel est le statut de jurer par un autre qu''Allah (par la Ka''bah, par son père, sur la tête de ses enfants, par l''honneur) ?'),
    (1062, N'tawhid_adoration', N'avance', N'Quelle fut la déclaration mémorable d''Ibn Mas''ûd comparant le faux serment par Allah et le serment véridique par un autre ?'),
    (1063, N'tawhid_adoration', N'avance', N'Pourquoi est-il interdit de dire : ''C''est ce qu''Allah a voulu ET ce que tu as voulu'' ?'),
    (1064, N'tawhid_adoration', N'avance', N'Quel est le nom le plus détesté auprès d''Allah le Jour de la Résurrection d''après le Sahîh Al-Bukhârî ?'),
    (1065, N'tawhid_adoration', N'avance', N'Pourquoi le Prophète ﷺ a-t-il changé le surnom du Compagnon Abu Al-Hakam en ''Abu Churayh'' ?'),
    (1066, N'tawhid_adoration', N'avance', N'Quel est le statut de celui qui se moque d''une chose contenant la mention d''Allah, du Coran ou du Messager ﷺ ?'),
    (1067, N'tawhid_adoration', N'avance', N'Quelle est l''interdiction liée à l''usage de la conjonction ''Si'' (''Law'') lorsqu''un malheur frappe une personne ?'),
    (1068, N'tawhid_adoration', N'avance', N'Pourquoi est-il interdit d''insulter le vent ou les phénomènes naturels ?'),
    (1069, N'tawhid_adoration', N'avance', N'Quel est le jugement religieux sur l''acte d''insulter le temps ou l''époque (Ad-Dahr) lorsque survient une difficulté ?'),
    (1070, N'tawhid_adoration', N'avance', N'Quelle est l''interdiction de donner aux enfants des noms exprimant la servitude à un autre qu''Allah (comme ''Abd An-Nabî, ''Abd Al-Ka''bah, ''Abd ''Amr) ?'),
    (1071, N'tawhid_preservation', N'debutant', N'Quel est le statut de porter un anneau, un fil ou un bracelet de cuivre dans le but de repousser ou de guérir une maladie ?'),
    (1072, N'tawhid_preservation', N'debutant', N'Que dit le hadith rapporté par ''Uqba ibn ''Âmir concernant celui qui accroche une amulette (Tamîmah) ?'),
    (1073, N'tawhid_preservation', N'debutant', N'Quelle fut la réaction du noble Compagnon Hudhayfa en voyant un homme porter un fil à la main contre la fièvre ?'),
    (1074, N'tawhid_preservation', N'debutant', N'Que désigne le terme ''Tamâ''im'' (amulettes) dans les traditions prophétiques ?'),
    (1075, N'tawhid_preservation', N'debutant', N'Quelle est la règle concernant les incantations (Ruqâ) d''après le hadith ''Les Ruqâ, les amulettes et la Tiwala sont du Shirk'' ?'),
    (1076, N'tawhid_preservation', N'debutant', N'Qu''est-ce que la ''Tiwala'' mentionnée dans les hadiths prophétiques ?'),
    (1077, N'tawhid_preservation', N'debutant', N'Quelle action le Prophète ﷺ a-t-il ordonnée lors d''un voyage concernant les colliers en corde d''arc pendus au cou des chameaux ?'),
    (1078, N'tawhid_preservation', N'debutant', N'Quelle récompense est équivalente à celle de couper une amulette portée par une personne selon Sa''îd ibn Jubayr ?'),
    (1079, N'tawhid_preservation', N'debutant', N'Quelle fut la demande formulée par certains nouveaux musulmans lors de la bataille de Hunayn concernant l''arbre nommé ''Dhâtu Anwât'' ?'),
    (1080, N'tawhid_preservation', N'debutant', N'Quelle fut la réaction véhémente du Prophète ﷺ à cette demande de ''Dhâtu Anwât'' ?'),
    (1081, N'tawhid_preservation', N'intermediaire', N'Qu''est-ce que la ''Tiyarah'' ou l''augure dénoncé dans les versets et hadiths ?'),
    (1082, N'tawhid_preservation', N'intermediaire', N'Que signifie la parole prophétique : ''Il n''y a ni contagion (autonome), ni augure, ni hibou, ni mois de Safar'' ?'),
    (1083, N'tawhid_preservation', N'intermediaire', N'Quel est le comportement apprécié par le Prophète ﷺ par opposition au mauvais présage superstitieux ?'),
    (1084, N'tawhid_preservation', N'intermediaire', N'Quelle est l''expiation enseignée par le Prophète ﷺ si une pensée d''augure superstitieux survient dans l''esprit d''un musulman ?'),
    (1085, N'tawhid_preservation', N'intermediaire', N'Quel est le jugement religieux attribué à la demande de pluie par les phases lunaires ou les astres (''An-Naw'') ?'),
    (1086, N'tawhid_preservation', N'intermediaire', N'Quel est le statut de placer sa confiance totale (Tawakkul) en une créature ou en un moyen matériel en oubliant Allah ?'),
    (1087, N'tawhid_preservation', N'intermediaire', N'Quels sont les deux péchés destructeurs du cœur cités dans les sourates Al-A''râf (v. 99) et Al-Hijr (v. 56) ?'),
    (1088, N'tawhid_preservation', N'intermediaire', N'Que dit le verset de la sourate At-Taghâbun (v. 11) au sujet de celui qui patiente face aux épreuves du destin ?'),
    (1089, N'tawhid_preservation', N'intermediaire', N'Quelle parole prophétique dénonce la recherche de la satisfaction des gens au prix du courroux d''Allah ?'),
    (1090, N'tawhid_preservation', N'intermediaire', N'Comment le Prophète ﷺ qualifie-t-il celui qui accomplit ses œuvres religieuses (prière, aumône, combat) dans le seul but d''obtenir des richesses matérielles de ce bas-monde ?'),
    (1091, N'tawhid_preservation', N'avance', N'Quel est le statut jurisprudentiel de la sorcellerie (Sihr) en Islam ?'),
    (1092, N'tawhid_preservation', N'avance', N'Où figure la sorcellerie parmi la liste des grands péchés décrits par le Prophète ﷺ ?'),
    (1093, N'tawhid_preservation', N'avance', N'Quelle est la peine légale prescrite contre le sorcier prouvé selon les jugements des Compagnons (''Umar, Hafsa, Jundub) ?'),
    (1094, N'tawhid_preservation', N'avance', N'Quelles pratiques superstitieuses sont assimilées à la sorcellerie dans le hadith de Qatan ibn Qabîsa ?'),
    (1095, N'tawhid_preservation', N'avance', N'Quel est le jugement sur l''apprentissage de l''astrologie judiciaire (prétendre lire l''avenir d''un individu selon sa date de naissance et les constellations) ?'),
    (1096, N'tawhid_preservation', N'avance', N'Quelle est la punition spirituelle formulée à l''encontre de celui qui se rend chez un devin ou un voyant (''Kâhin'' ou ''Arrâf) et l''interroge sur l''invisible ?'),
    (1097, N'tawhid_preservation', N'avance', N'Que se passe-t-il si la personne va voir le devin/voyant ET croit en ses prétentions de connaître l''invisible ?'),
    (1098, N'tawhid_preservation', N'avance', N'Comment les devins obtiennent-ils parfois des parcelles d''informations réelles mélangées à cent mensonges ?'),
    (1099, N'tawhid_preservation', N'avance', N'Qu''est-ce que la ''Nuchra'' (défaire un sortilège) et quelle forme est interdite en Islam ?'),
    (1100, N'tawhid_preservation', N'avance', N'Quelles sont les trois seules raisons légitimes pour lesquelles Allah a créé les étoiles selon le grand savant Qatâda ?');

INSERT INTO dbo.choix (question_id, choix, est_correct) VALUES
    (1001, N'Pour qu''ils l''adorent de manière exclusive sans rien Lui associer', 1),
    (1001, N'Pour qu''ils recherchent la subsistance et le savoir', 0),
    (1001, N'Pour qu''ils observent les signes de la nature', 0),
    (1001, N'Pour qu''ils peuplent la Terre et l''aménagent', 0),
    (1002, N'Lutter uniquement contre l''injustice sociale', 0),
    (1002, N'Enseigner les règles des transactions financières', 0),
    (1002, N'Etablir des états et des gouvernements', 0),
    (1002, N'Ordonner d''adorer Allah Seul et de s''écarter du Tâghût', 1),
    (1003, N'Tout ce qui est adoré en dehors d''Allah avec son consentement, ainsi que le diable et les guides de l''égarerment', 1),
    (1003, N'Les rois et dirigeants uniquement', 0),
    (1003, N'Les passions humaines personnelles', 0),
    (1003, N'Uniquement les idoles taillées dans la pierre', 0),
    (1004, N'Qu''ils accomplissent 50 prières quotidiennes', 0),
    (1004, N'Qu''ils fassent le pèlerinage chaque année', 0),
    (1004, N'Qu''ils l''adorent sans rien Lui associer', 1),
    (1004, N'Qu''ils jeûnent tous les mois de l''année', 0),
    (1005, N'Qu''Il leur accorde la richesse dans le bas-monde', 0),
    (1005, N'Qu''Il les préserve de toutes les épreuves terrestres', 0),
    (1005, N'Qu''Il réalise tous leurs souhaits immédiatement', 0),
    (1005, N'Qu''Il ne châtie pas celui qui ne Lui associe rien', 1),
    (1006, N'Connaître l''arabe littéraire couramment', 0),
    (1006, N'Renier le Tâghût et désavouer l''associationnisme (Shirk)', 1),
    (1006, N'Avoir effectué le pèlerinage à La Mecque', 0),
    (1006, N'Prononcer des formules de dhikr à voix haute', 0),
    (1007, N'Parce que la révélation n''était pas encore complète', 0),
    (1007, N'De peur que les gens ne se reposent dessus et négligent les œuvres obligatoires', 1),
    (1007, N'Parce que c''était un secret réservé aux érudits', 0),
    (1007, N'Pour éviter la jalousie entre les Compagnons', 0),
    (1008, N'Par l''ordre d''adorer Allah Seul et de ne rien Lui associer', 1),
    (1008, N'Par l''obligation d''acquitter la Zakât', 0),
    (1008, N'Par l''obligation de la bonté envers les parents', 0),
    (1008, N'Par l''interdiction du vol et du meurtre', 0),
    (1009, N'Ne pas associer quoi que ce soit à Allah', 1),
    (1009, N'Ne pas vous approcher des turpitudes', 0),
    (1009, N'Ne pas tuer vos enfants par crainte de la pauvreté', 0),
    (1009, N'Etre bon envers vos père et mère', 0),
    (1010, N'L''organisation des armées', 0),
    (1010, N'L''obligation de construire des mosquées', 0),
    (1010, N'Les versets de la sourate Al-An''âm ordonnant le Tawhid et l''interdiction du Shirk', 1),
    (1010, N'L''ordre d''écrire des livres de jurisprudence', 0),
    (1011, N'Une grande injustice (Thulm ''Athîm)', 1),
    (1011, N'Une simple erreur d''interprétation', 0),
    (1011, N'Un manquement mineur aux règles de politesse', 0),
    (1011, N'Une faiblesse passagère de la foi', 0),
    (1012, N'Allah le fera entrer au Paradis quelles que soient ses œuvres', 1),
    (1012, N'Il aura la vision d''Allah dans le bas-monde', 0),
    (1012, N'Allah lui donne la richesse matérielle', 0),
    (1012, N'Il sera dispensé des épreuves de la tombe', 0),
    (1013, N'Allah a interdit à l''Enfer toute personne qui dit ''Lâ ilâha illâ Allâh'' en recherchant la Face d''Allah', 1),
    (1013, N'La formule du Tawhid suffit sans accomplir la prière', 0),
    (1013, N'L''Enfer est éternel pour tous les pécheurs', 0),
    (1013, N'Ceux qui disent la formule du Tawhid n''auront aucun compte à rendre', 0),
    (1014, N'Elle équivaut au poids du Trône d''Allah', 0),
    (1014, N'Elle est plus précieuse que tout l''or de l''univers', 0),
    (1014, N'Si les sept cieux et les sept terres étaient sur un plateau et ''Lâ ilâha illâ Allâh'' sur l''autre, cette formule l''emporterait', 1),
    (1014, N'Elle pèse plus lourd que les montagnes de la Terre', 0),
    (1015, N'Il viendra à lui avec autant de pardon', 1),
    (1015, N'Il lui pardonnera la moitié de ses péchés', 0),
    (1015, N'Il lui demandera de reconstruire la Terre', 0),
    (1015, N'Il le punira d''abord puis le graciera', 0),
    (1016, N'Avoir accompli des œuvres surérogatoires continues', 0),
    (1016, N'S''isoler complètement du monde', 0),
    (1016, N'Mourir sur l''unicité absolue (Tawhid) sans commettre de Shirk', 1),
    (1016, N'Faire partie d''une lignée noble', 0),
    (1017, N'Qu''il a été crucifié pour les péchés des hommes', 0),
    (1017, N'Qu''il est le fils de Dieu', 0),
    (1017, N'Qu''il est le serviteur d''Allah, Son messager, Sa parole transmise à Marie et un esprit venant de Lui', 1),
    (1017, N'Qu''il est un ange sous forme humaine', 0),
    (1018, N'Qu''Allah l''a créé par Sa parole ''Sois'' (Kun)', 1),
    (1018, N'Qu''il n''a parlé qu''en lisant les écritures', 0),
    (1018, N'Que Jésus est une partie de la parole divine', 0),
    (1018, N'Que la parole d''Allah s''est incarnée en lui', 0),
    (1019, N'Parce qu''elle doit être répétée 1000 fois par jour', 0),
    (1019, N'Parce qu''elle exige la croyance du cœur et la sincérité (Ikhlâs)', 1),
    (1019, N'Parce qu''il faut l''écrire sur un papier', 0),
    (1019, N'Parce qu''elle doit être dite en public seulement', 0),
    (1020, N'Ceux qui n''ont jamais été injustes envers leurs voisins', 0),
    (1020, N'Ceux qui n''ont pas mélangé leur foi avec le Shirk', 1),
    (1020, N'Ceux qui pratiquent le jugement équitable', 0),
    (1020, N'Ceux qui ne commettent aucun péché mineur', 0),
    (1021, N'Ils connaîtront la date exacte du Jour Dernier', 0),
    (1021, N'Ils recevront le pouvoir politique sur Terre', 0),
    (1021, N'Ils entreront au Paradis sans jugement ni châtiment préalable', 1),
    (1021, N'Ils vivront plus de cent ans sur Terre', 0),
    (1022, N'Un roi puissant et un riche commerçant', 0),
    (1022, N'Un poète éloquent et un grand voyageur', 0),
    (1022, N'Un juge séculier et un stratège militaire', 0),
    (1022, N'Un guide parfait (Ummah), soumis à Allah (Qânit), monothéiste pur (Hanîf) et n''étant pas du nombre des polythéistes', 1),
    (1023, N'Ceux qui ont accompli 100 pèlerinages', 0),
    (1023, N'Ceux qui ne demandent pas de Ruqyah, ne pratiquent pas la cautérisation, ne croient pas aux augures et s''en remettent à leur Seigneur', 1),
    (1023, N'Ceux qui se sont isolés dans les montagnes pour prier', 0),
    (1023, N'Ceux qui ont écrit des livres de théologie', 0),
    (1024, N'''Ukâshah ibn Mihsan', 1),
    (1024, N'Khâlid ibn Al-Walîd', 0),
    (1024, N'''Umar ibn Al-Khattâb', 0),
    (1024, N'Abu Bakr As-Siddîq', 0),
    (1025, N'Allah ne pardonne pas qu''on Lui associe quoi que ce soit, mais Il pardonne ce qui est en deçà à qui Il veut', 1),
    (1025, N'Le Shirk est un péché comme les autres péchés majeurs', 0),
    (1025, N'Allah le pardonne après un certain temps en Enfer', 0),
    (1025, N'Allah pardonne le Shirk majeur mais pas le Shirk mineur', 0),
    (1026, N'Fais que tous les hommes deviennent riches', 0),
    (1026, N'Accorde-moi une descendance exempte de toute maladie', 0),
    (1026, N'Seigneur, donne-moi le royaume de la Terre', 0),
    (1026, N'Écarte-moi ainsi que mes fils de l''adoration des idoles', 1),
    (1027, N'La pauvreté et la famine', 0),
    (1027, N'Les invasions des nations étrangères', 0),
    (1027, N'La baisse des récoltes agricoles', 0),
    (1027, N'Le Shirk mineur, à savoir l''ostentation (Riyâ'')', 1),
    (1028, N'Il restera au Purgatoire (Al-A''râf)', 0),
    (1028, N'Il entrera en Enfer', 1),
    (1028, N'Il sera jugé avec indulgence', 0),
    (1028, N'Ses bonnes œuvres effaceront son erreur', 0),
    (1029, N'Rencontrer Allah sans rien Lui associer', 1),
    (1029, N'Ne jamais avoir commis d''erreur dans sa vie', 0),
    (1029, N'Avoir accompli le pèlerinage au moins dix fois', 0),
    (1029, N'Être issu de la tribu des Quraysh', 0),
    (1030, N'Parce qu''ils ne tombent jamais malades', 0),
    (1030, N'Parce que la Ruqyah est strictement interdite dans tous les cas', 0),
    (1030, N'Parce qu''ils ne connaissent pas les versets coraniques', 0),
    (1030, N'Parce qu''ils préfèrent la dépendance directe et exclusive envers Allah sans solliciter de médiateur humain', 1),
    (1031, N'Chercher le pouvoir politique avant tout', 0),
    (1031, N'Appeler à Allah avec clairvoyance et science (Basîrah)', 1),
    (1031, N'Imposer la foi par la contrainte verbale', 0),
    (1031, N'Débattre sans méthode ni preuve', 0),
    (1032, N'Par l''explication des règles de la Zakât et de l''aumône', 0),
    (1032, N'Par la mise en place des tribunaux', 0),
    (1032, N'Par l''appel à l''attestation qu''aucune divinité n''est digne d''adoration en dehors d''Allah (Tawhid)', 1),
    (1032, N'Par l''enseignement des peines légales', 0),
    (1033, N'Prière -> Zakât -> Tawhid', 0),
    (1033, N'Tawhid -> Prière -> Zakât', 1),
    (1033, N'Zakât -> Tawhid -> Jeûne', 0),
    (1033, N'Pèlerinage -> Prière -> Tawhid', 0),
    (1034, N'Abu Bakr As-Siddîq', 0),
    (1034, N'''Umar ibn Al-Khattâb', 0),
    (1034, N'Sa''d ibn Abî Waqqâs', 0),
    (1034, N'''Ali ibn Abî Tâlib', 1),
    (1035, N'De détruire leurs récoltes', 0),
    (1035, N'D''attaquer immédiatement par surprise', 0),
    (1035, N'De ne pas leur parler et de commencer la bataille', 0),
    (1035, N'D''avancer paisiblement, de les appeler à l''Islam et de leur faire connaître les droits d''Allah', 1),
    (1036, N'Cela garantit la royauté sur Terre', 0),
    (1036, N'Cela équivaut à 100 ans de prière surérogatoire', 0),
    (1036, N'Cela efface les dettes financières', 0),
    (1036, N'Cela vaut mieux que d''avoir des chameaux rouges (les biens terrestres les plus précieux)', 1),
    (1037, N'Le fait de leur offrir des cadeaux', 0),
    (1037, N'Le fait de respecter leur savoir jurisprudentiel', 0),
    (1037, N'Le fait de leur obéir dans la modification du licite et de l''illicite en désobéissance aux ordres d''Allah', 1),
    (1037, N'Le fait de demander des conseils médicaux aux savants', 0),
    (1038, N'Que ''Lâ ilâha illâ Allâh'' comporte deux piliers : le désaveu (An-Nafy) de toute idole et l''affirmation (Al-Ithbât) pour Allah Seul', 1),
    (1038, N'Qu''il est permis de prier vers les tombes des ancêtres', 0),
    (1038, N'Que les idoles avaient une certaine utilité temporaire', 0),
    (1038, N'Qu''Ibrâhîm adorait les étoiles avant de créer la terre', 0),
    (1039, N'Aimer leurs enfants et leurs épouses', 0),
    (1039, N'Aimer leur patrie d''origine', 0),
    (1039, N'Préférer la nourriture fine', 0),
    (1039, N'Donner à Allah des égaux qu''ils aiment d''un amour égal ou supérieur à celui qu''ils vouent à Allah', 1),
    (1040, N'S''engager dans le commerce international', 0),
    (1040, N'Dire ''Lâ ilâha illâ Allâh'' ET renier tout ce qui est adoré en dehors d''Allah', 1),
    (1040, N'La simple appartenance géographique', 0),
    (1040, N'Payer des taxes à l''État', 0),
    (1041, N'Un acte recommandé si l''intention est bonne', 0),
    (1041, N'Un Shirk majeur qui fait sortir de l''Islam', 1),
    (1041, N'Une simple désobéissance mineure', 0),
    (1041, N'Une tradition culturelle permise', 0),
    (1042, N'Qu''Allah maudisse celui qui sacrifie un animal pour un autre qu''Allah', 1),
    (1042, N'Qu''Allah maudisse celui qui vend de la viande avariée', 0),
    (1042, N'Qu''Allah maudisse celui qui oublie de dire Bismillah', 0),
    (1042, N'Qu''Allah maudisse celui qui ne mange pas de viande', 0),
    (1043, N'Parce qu''il a accepté de sacrifier une simple mouche à une idole pour pouvoir passer', 1),
    (1043, N'Parce qu''il a menti aux gardes', 0),
    (1043, N'Parce qu''il a tué une mouche volontairement', 0),
    (1043, N'Parce qu''il a refusé de donner une aumône', 0),
    (1044, N'Parce qu''il a détruit l''idole avec son épée', 0),
    (1044, N'Parce qu''il a offert de l''or aux pauvres', 0),
    (1044, N'Parce qu''il a catégoriquement refusé de sacrifier quoi que ce soit pour un autre qu''Allah et a été exécuté', 1),
    (1044, N'Parce qu''il a réussi à s''enfuir par la ruse', 0),
    (1045, N'Si le lieu contenait une idole de la Jâhiliyya ou si les idolâtres y célébraient une de leurs fêtes', 1),
    (1045, N'Si le chameau était de couleur blanche', 0),
    (1045, N'Si l''homme était marié ou célibataire', 0),
    (1045, N'Si la viande allait être distribuée aux riches', 0),
    (1046, N'C''est une tradition acceptable si on donne aussi de l''argent aux pauvres', 0),
    (1046, N'C''est un vœu qui doit être accompli obligatoirement', 0),
    (1046, N'C''est un acte de Shirk majeur car le vœu est une adoration exclusive d''Allah', 1),
    (1046, N'C''est un acte recommandé pour obtenir la guérison', 0),
    (1047, N'Elle doit accomplir son vœu sans hésiter', 0),
    (1047, N'Elle doit demander la permission à son imam', 0),
    (1047, N'Il lui est strictement interdit d''accomplir ce vœu de désobéissance', 1),
    (1047, N'Elle doit jeûner trois ans', 0),
    (1048, N'C''est une protection efficace sans danger', 0),
    (1048, N'C''est du Shirk car chercher refuge est une adoration réservée à Allah Seul', 1),
    (1048, N'C''est permis si on dit aussi Bismillah', 0),
    (1048, N'C''est une recommandation des voyageurs anciens', 0),
    (1049, N'Je jette du sel sur le sol', 0),
    (1049, N'Je demande la protection aux maîtres de cette vallée', 0),
    (1049, N'Je cherche refuge auprès des paroles parfaites d''Allah contre le mal de ce qu''Il a créé', 1),
    (1049, N'Je salue les esprits de cette terre', 0),
    (1050, N'Demander à un mort est préférable car il est plus proche d''Allah', 0),
    (1050, N'Demander l''aide d''un vivant capable pour une chose terrestre est permis ; implorer un mort ou un absent est une adoration exclusive (Shirk majeur)', 1),
    (1050, N'Il n''y a aucune différence', 0),
    (1050, N'Les deux sont interdits', 0),
    (1051, N'Aux saints pieux dans leurs tombeaux', 0),
    (1051, N'Aux anges et aux prophètes uniquement', 0),
    (1051, N'À la communauté des croyants', 0),
    (1051, N'À Allah Seul dans sa totalité', 1),
    (1052, N'L''accord des savants et de la famille', 0),
    (1052, N'La récitation de poèmes de louange', 0),
    (1052, N'Que l''intercesseur soit riche et noble', 0),
    (1052, N'La permission accordée par Allah à l''intercesseur ET Son agrément pour celui en faveur de qui on intercède', 1),
    (1053, N'L''étude de la philosophie grecque', 0),
    (1053, N'L''amour de l''argent et du commerce', 0),
    (1053, N'L''exagération (Ghuluww) dans la vénération des hommes pieux (Wadd, Suwâ'', Yaghûth, Ya''ûq, Nasr) et la réalisation de leurs statues', 1),
    (1053, N'L''abandon de l''agriculture', 0),
    (1054, N'Ne construisez pas de maisons élevées à Médine', 0),
    (1054, N'Ne donnez pas mon prénom à vos enfants', 0),
    (1054, N'Ne me délaissez pas pendant vos voyages', 0),
    (1054, N'N''exagérez pas à mon sujet comme les chrétiens ont exagéré au sujet du fils de Marie. Je ne suis qu''un serviteur, dites : Le serviteur d''Allah et Son Messager', 1),
    (1055, N'Ils ont pris les tombes de leurs prophètes comme des lieux de prière et de culte', 1),
    (1055, N'Ils les ont recouvertes de pierre noire', 0),
    (1055, N'Ils ont oublié l''emplacement de leurs tombes', 0),
    (1055, N'Ils ont refusé de les enterrer dans la terre', 0),
    (1056, N'Des serviteurs excusables', 0),
    (1056, N'Des architectes habiles', 0),
    (1056, N'Des croyants zélés et respectueux', 0),
    (1056, N'Les pires des créatures auprès d''Allah le Jour de la Résurrection', 1),
    (1057, N'Elle a été élevée au-dessus du toit de la mosquée', 0),
    (1057, N'Elle a été entourée d''un mur sans porte dans la chambre d''Aïcha pour empêcher l''accès direct', 1),
    (1057, N'Elle a été verrouillée avec sept clés d''or', 0),
    (1057, N'Elle a été cachée dans le désert', 0),
    (1058, N'Ô Seigneur ! Ne fais pas de ma tombe une idole (Wathan) qui soit adorée', 1),
    (1058, N'Seigneur, accorde la richesse à ceux qui me rendent visite', 0),
    (1058, N'Seigneur, augmente le nombre de visiteurs de ma tombe', 0),
    (1058, N'Seigneur, fais que ma tombe soit couverte d''or', 0),
    (1059, N'Il lui a demandé de prier pour lui aussi', 0),
    (1059, N'Il lui a donné de l''argent', 0),
    (1059, N'Il lui a interdit cela en citant le hadith : ''Ne faites pas de ma tombe un lieu de fête habituel et priez sur moi où que vous soyez''', 1),
    (1059, N'Il l''a encouragé à continuer', 0),
    (1060, N'Un acte toléré si la mosquée est sombre', 0),
    (1060, N'Un acte strictement interdit et maudit par le Prophète ﷺ', 1),
    (1060, N'Une tradition recommandée le vendredi', 0),
    (1060, N'Une coutume sans importance', 0),
    (1061, N'Une marque de politesse traditionnelle', 0),
    (1061, N'Une promesse juridiquement contraignante', 0),
    (1061, N'Un serment solennel recommandé', 0),
    (1061, N'Du Shirk mineur (ou Kufr) qui altère la vénération due à Allah Seul', 1),
    (1062, N'Le faux serment est plus grave dans tous les cas', 0),
    (1062, N'Je préfère jurer mensongèrement par Allah que de jurer véridiquement par un autre que Lui', 1),
    (1062, N'Les deux sont identiques', 0),
    (1062, N'Il vaut mieux jurer par la Ka''bah en disant la vérité', 0),
    (1063, N'Parce que la conjonction ''ET'' (''Wa'') associe la volonté de la créature au même niveau que celle d''Allah ; il faut dire ''Puis ce que tu as voulu'' (''Thumma'')', 1),
    (1063, N'Parce que c''est une phrase trop longue', 0),
    (1063, N'Parce qu''il ne faut jamais parler de la volonté divine', 0),
    (1063, N'Parce que la créature n''a aucune volonté', 0),
    (1064, N'Un homme qui s''appelle ''Pharaon''', 0),
    (1064, N'Un homme qui n''a pas de nom arabe', 0),
    (1064, N'Un homme qui se fait appeler ''Le Roi des rois'' (Shâhinshâh) ou ''Le Juge des juges''', 1),
    (1064, N'Un homme qui change souvent de nom', 0),
    (1065, N'Parce qu''il n''aimait pas la sonorité du nom', 0),
    (1065, N'Parce qu''il appartenait à une autre tribu', 0),
    (1065, N'Parce qu''Al-Hakam (Le Juge Suprême) est l''un des Noms exclusifs d''Allah et que le jugement absolu Lui appartient', 1),
    (1065, N'Parce qu''Abu Churayh était son fils le plus jeune', 0),
    (1066, N'Un acte détestable mais pardonné automatiquement', 0),
    (1066, N'Un manque de politesse qui nécessite de demander pardon aux gens', 0),
    (1066, N'Une simple plaisanterie sans gravité', 0),
    (1066, N'De la mécréance (Kufr) majeure qui fait sortir de l''Islam même s''il prétendait s''amuser', 1),
    (1067, N'Le mot ''Si'' annule les ablutions', 0),
    (1067, N'Il est interdit d''utiliser le mot ''Si'' dans la grammaire arabe', 0),
    (1067, N'Il faut dire ''Si'' au moins dix fois par jour', 0),
    (1067, N'Il est interdit d''utiliser ''Si'' pour exprimer le regret et le mécontentement face au destin, car ''Si'' ouvre la porte au travail du démon', 1),
    (1068, N'Parce que le vent porte les prières', 0),
    (1068, N'Parce que le vent est soumis aux ordres d''Allah ; insulter le vent revient à insulter Celui qui le dirige et le commande', 1),
    (1068, N'Parce que cela fatigue la voix', 0),
    (1068, N'Parce que le vent peut devenir plus violent', 0),
    (1069, N'C''est une façon normale d''exprimer sa tristesse', 0),
    (1069, N'C''est permis pendant la guerre', 0),
    (1069, N'C''est une injure envers Allah car Allah est le Créateur du temps et le Gestionnaire de la nuit et du jour', 1),
    (1069, N'C''est un poème traditionnel arabe', 0),
    (1070, N'Ces noms sont permis pour les non-arabes', 0),
    (1070, N'Il y a un consensus des savants (Ijmâ'') sur l''interdiction absolue de tout nom exprimant la servitude à autre qu''Allah', 1),
    (1070, N'Ces noms sont détestables mais autorisés', 0),
    (1070, N'Ce sont des noms bénis', 0),
    (1071, N'Une Sunna délaissée', 0),
    (1071, N'Une pratique médicale recommandée', 0),
    (1071, N'Une forme de Shirk (associationnisme)', 1),
    (1071, N'Une tradition culturelle neutre', 0),
    (1072, N'Qu''il est excusé s''il est ignorant', 0),
    (1072, N'Qu''Allah n''accomplisse pas ses souhaits et qu''il a commis un acte d''association (Shirk)', 1),
    (1072, N'Qu''Allah guérira son mal rapidement', 0),
    (1072, N'Qu''il doit payer une expiation en deuil', 0),
    (1073, N'Il lui a dit de le cacher sous la manche', 0),
    (1073, N'Il n''a rien dit pour ne pas le blesser', 0),
    (1073, N'Il l''a coupé et a récité le verset : ''Et la plupart d''entre eux ne croient en Allah qu''en Lui associant des égaux''', 1),
    (1073, N'Il lui a demandé où il l''avait acheté', 0),
    (1074, N'Des objets, coquillages ou tissus accrochés aux enfants ou animaux pour repousser le mauvais œil', 1),
    (1074, N'Des vêtements en laine brute', 0),
    (1074, N'Des pièces de monnaie anciennes', 0),
    (1074, N'Des remèdes à base d''herbes naturelles', 0),
    (1075, N'Seules les incantations contenant du Shirk ou des formules incompréhensibles sont interdites ; la Ruqyah par le Coran et les invocations licites est permise', 1),
    (1075, N'Les Ruqâ sont autorisées uniquement pendant le Ramadan', 0),
    (1075, N'Toutes les incantations sont absolument interdites sans exception', 0),
    (1075, N'La Tiwala est autorisée pour réconcilier les époux', 0),
    (1076, N'Un plat traditionnel consommé le jour de la fête', 0),
    (1076, N'Une transaction commerciale avec intérêt', 0),
    (1076, N'Une magie ou talisman prétendant faire aimer artificiellement un homme à sa femme et vice-versa', 1),
    (1076, N'Un type de prière nocturne', 0),
    (1077, N'De les vendre au marché', 0),
    (1077, N'De les bénir par des invocations', 0),
    (1077, N'De couper tous les colliers en corde d''arc sans en laisser un seul', 1),
    (1077, N'De les remplacer par des colliers en cuir', 0),
    (1078, N'L''équivalent d''un jeûne d''un mois', 0),
    (1078, N'L''équivalent d''un pèlerinage surérogatoire', 0),
    (1078, N'L''équivalent d''une aumône de 1000 dinars', 0),
    (1078, N'L''équivalent de l''affranchissement d''un esclave', 1),
    (1079, N'De leur désigner un arbre semblable pour y accrocher leurs armes et en chercher la bénédiction (Tabarruk)', 1),
    (1079, N'De couper cet arbre pour en faire du bois de chauffage', 0),
    (1079, N'D''en faire le point de rassemblement de l''armée', 0),
    (1079, N'De prier sous cet arbre à l''ombre', 0),
    (1080, N'Il a souri et a accepté leur demande', 0),
    (1080, N'Il leur a infligé une amende financière', 0),
    (1080, N'Il leur a ordonné de retourner à Médine', 0),
    (1080, N'Il a dit : ''Allâhu Akbar ! Ce sont les voies du passé ! Vous avez dit comme les enfants d''Israël ont dit à Moïse : Désigne-nous une divinité comme leurs dieux''', 1),
    (1081, N'Le pessimisme superstitieux tiré de la vue d''un animal, d''un chiffre, d''une personne ou d''un événement', 1),
    (1081, N'L''anticipation des tempêtes en mer', 0),
    (1081, N'Le calcul de la trajectoire des oiseaux migrateurs', 0),
    (1081, N'Le fait de voyager de nuit', 0),
    (1082, N'Négation des croyances païennes attribuant une puissance néfaste ou un mauvais sort au hibou, au mois de Safar ou à la contagion sans la volonté d''Allah', 1),
    (1082, N'Que les maladies n''existent pas', 0),
    (1082, N'Qu''il faut tuer les hiboux', 0),
    (1082, N'Qu''il faut éviter de sortir en mois de Safar', 0),
    (1083, N'La méfiance envers autrui', 0),
    (1083, N'L''isolement complet', 0),
    (1083, N'Le Fâ''l (l''optimisme et la bonne parole qui réjouit le cœur)', 1),
    (1083, N'L''insouciance absolue', 0),
    (1084, N'Donner dix pièces d''argent aux pauvres', 0),
    (1084, N'Dire : ''Ô Allah ! Nul n''apporte le bien si ce n''est Toi, nul ne repousse le mal si ce n''est Toi, et il n''y a de force ni de puissance que par Toi''', 1),
    (1084, N'Rentrer chez soi et renoncer à son voyage', 0),
    (1084, N'Jeûner deux jours consécutifs', 0),
    (1085, N'Une coutume arabe louable', 0),
    (1085, N'Une prière de rogation', 0),
    (1085, N'Une prévision météorologique scientifiquement exacte', 0),
    (1085, N'De la mécréance (Kufr) si l''on croit que l''étoile crée la pluie, ou du Shirk mineur si on la croit cause autonome', 1),
    (1086, N'C''est de l''organisation intelligente', 0),
    (1086, N'C''est une altération grave du Tawhid (Shirk dans le Tawakkul)', 1),
    (1086, N'C''est une obligation professionnelle', 0),
    (1086, N'C''est une faiblesse sans gravité', 0),
    (1087, N'L''amour de la musique et de la poésie', 0),
    (1087, N'Se sentir à l''abri de la ruse/châtiment d''Allah (Al-Amn min makrillâh) ET désespérer de Sa miséricorde (Al-Qunût min rahmatillâh)', 1),
    (1087, N'La gourmandise et la paresse', 0),
    (1087, N'L''ignorance de la géographie et de l''histoire', 0),
    (1088, N'Et quiconque croit en Allah, Il guide son cœur', 1),
    (1088, N'Il ne connaîtra plus jamais la maladie', 0),
    (1088, N'Ses proches seront tous préservés', 0),
    (1088, N'Il obtiendra une compensation financière immédiate', 0),
    (1089, N'Il faut satisfaire tout le monde à n''importe quel prix', 0),
    (1089, N'Rechercher la popularité est une vertu religieuse', 0),
    (1089, N'Quiconque recherche l''agrément d''Allah en suscitant la colère des gens, Allah le suffira contre les gens ; et quiconque recherche l''agrément des gens en suscitant la colère d''Allah, Allah le laissera à la merci des gens', 1),
    (1089, N'Les éloges des gens sont la preuve du Paradis', 0),
    (1090, N'L''esclave du dinar, l''esclave du dirham, l''esclave des beaux vêtements (Ta''isa ''Abd ad-dînâr)', 1),
    (1090, N'Un croyant malchanceux', 0),
    (1090, N'Un serviteur ordinaire', 0),
    (1090, N'Un commerçant avisé', 0),
    (1091, N'Un art de spectacle toléré', 0),
    (1091, N'Une science occulte neutre', 0),
    (1091, N'Un péché mineur effacé par les ablutions', 0),
    (1091, N'De la mécréance (Kufr) majeure qui fait sortir de l''Islam', 1),
    (1092, N'Elle ne fait pas partie des grands péchés', 0),
    (1092, N'Elle est le deuxième des sept péchés capitaux (Al-Mûbiqât) juste après le Shirk', 1),
    (1092, N'Elle est classée après le vol et l''usure', 0),
    (1092, N'Elle est le dernier des grands péchés', 0),
    (1093, N'L''exil hors de la ville pendant un an', 0),
    (1093, N'Une amende financière', 0),
    (1093, N'L''emprisonnement à perpétuité', 0),
    (1093, N'La peine de mort par le sabre sans demande de repentir', 1),
    (1094, N'Le calcul mental et l''écriture', 0),
    (1094, N'L''observation des nuages pour la pluie', 0),
    (1094, N'La ''Iyâfa (effrayer les oiseaux pour lire l''avenir), le Tarq (tracer des traits sur le sable) et l''augure', 1),
    (1094, N'La mesure du temps par l''ombre', 0),
    (1095, N'C''est un divertissement sans conséquence', 0),
    (1095, N'C''est une branche de la science astronomique', 0),
    (1095, N'C''est l''apprentissage d''une branche de la sorcellerie', 1),
    (1095, N'C''est un moyen de connaître la subsistance', 0),
    (1096, N'Il doit donner l''équivalent de son salaire en aumône', 0),
    (1096, N'Il est privé de dormir une semaine', 0),
    (1096, N'Sa prière n''est pas acceptée pendant quarante jours', 1),
    (1096, N'Il doit refaire son pèlerinage', 0),
    (1097, N'Elle commet un péché mineur', 0),
    (1097, N'Elle a mécru en ce qui a été révélé à Muhammad ﷺ', 1),
    (1097, N'Sa prière n''est pas acceptée pendant un an', 0),
    (1097, N'Elle doit réciter la sourate Al-Baqara', 0),
    (1098, N'Par les djinns qui interceptent furtivement une parole prononcée dans le ciel avant d''être frappés par les météores', 1),
    (1098, N'Par la lecture dans les pensées de l''interlocuteur', 0),
    (1098, N'Par l''analyse des rêves', 0),
    (1098, N'Par le calcul mathématique', 0),
    (1099, N'Utiliser des plantes médicinales est interdit', 0),
    (1099, N'La Nuchra est l''excision des enfants', 0),
    (1099, N'Défaire la sorcellerie par une autre sorcellerie semblable (travail des démons) est interdit ; la guérir par le Coran (Ruqyah) est permis', 1),
    (1099, N'La Nuchra est permise dans tous les cas', 0),
    (1100, N'Créer la chaleur, équilibrer la terre et prédire les guerres', 0),
    (1100, N'Calculer l''âge de l''univers, parler aux esprits et guider les rois', 0),
    (1100, N'Embellir le ciel, lapider les démons et servir de repères de direction pour les voyageurs', 1),
    (1100, N'Déterminer le destin des hommes, faire pleuvoir et décorer la terre', 0);

COMMIT TRANSACTION;
GO

-- ---- Vérification : 4 choix et 1 bonne réponse par question ----------------
SELECT q.categorie, q.niveau,
       COUNT(DISTINCT q.id)            AS nb_questions,
       COUNT(*)                        AS nb_choix,
       SUM(CAST(c.est_correct AS INT)) AS nb_bonnes_reponses
FROM dbo.questions q
JOIN dbo.choix c ON c.question_id = q.id
GROUP BY q.categorie, q.niveau
ORDER BY q.categorie, q.niveau;
GO
