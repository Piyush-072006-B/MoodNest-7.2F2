import SwiftUI

/// Manages mental health voice stories and bookmarking functionality
@MainActor
class VoicesManager: ObservableObject {
    static let shared = VoicesManager()
    
    @Published var bookmarkedVoiceIds: Set<UUID> = []
    
    private let bookmarksKey = "moodnest_bookmarkedVoices"
    
    init() {
        loadBookmarks()
    }
    
    // MARK: - Historical Figures (21 profiles)
    
    let historicalVoices: [MentalHealthVoice] = [
        // Abraham Lincoln
        MentalHealthVoice(
            name: "Abraham Lincoln",
            profession: "16th U.S. President",
            era: "1809-1865",
            condition: "Depression",
            quote: "I am now the most miserable man living. If what I feel were equally distributed to the whole human family, there would not be one cheerful face on the earth.",
            biography: "Abraham Lincoln struggled with severe depression throughout his life, experiencing what he called 'melancholy.' His bouts of depression were so intense that friends once removed razors from his room, fearing for his safety. Despite these struggles, Lincoln led the nation through its darkest hour—the Civil War—and abolished slavery. His resilience in the face of personal anguish demonstrates that mental health challenges need not define one's capacity for greatness. Lincoln's ability to channel his pain into empathy made him one of history's most compassionate leaders, proving that vulnerability and strength can coexist.",
            icon: "building.columns.fill",
            colorHex: "#8B7355",
            isHistorical: true
        ),
        
        // Virginia Woolf
        MentalHealthVoice(
            name: "Virginia Woolf",
            profession: "Novelist & Essayist",
            era: "1882-1941",
            condition: "Bipolar Disorder",
            quote: "I feel certain that I am going mad again. I feel we can't go through another of those terrible times.",
            biography: "Virginia Woolf, one of the most influential modernist writers, lived with bipolar disorder throughout her life. She experienced intense mood swings, from creative highs where words flowed effortlessly to devastating lows that left her unable to function. Despite these challenges, she produced masterpieces like 'Mrs. Dalloway' and 'To the Lighthouse,' revolutionizing narrative technique. Woolf's diaries reveal her acute self-awareness about her condition and her determination to create despite it. Her legacy reminds us that mental illness doesn't diminish artistic genius—it can coexist with extraordinary creativity and insight into the human condition.",
            icon: "book.fill",
            colorHex: "#9B59B6",
            isHistorical: true
        ),
        
        // Lionel Aldridge
        MentalHealthVoice(
            name: "Lionel Aldridge",
            profession: "NFL Player & Sportscaster",
            era: "1941-1998",
            condition: "Schizophrenia",
            quote: "I had to learn that mental illness is nothing to be ashamed of. It's a disease, just like diabetes or heart disease.",
            biography: "Lionel Aldridge was a Super Bowl champion with the Green Bay Packers who later became a successful sportscaster. In his late 30s, he was diagnosed with paranoid schizophrenia, which led to homelessness and the loss of his career. After receiving treatment, Aldridge became a powerful advocate for mental health awareness, speaking openly about his experiences. He traveled the country sharing his story, helping to destigmatize schizophrenia and encouraging others to seek help. His courage in speaking publicly about his illness at a time when mental health was rarely discussed paved the way for greater understanding and compassion.",
            icon: "sportscourt.fill",
            colorHex: "#27AE60",
            isHistorical: true
        ),
        
        // Eugene O'Neill
        MentalHealthVoice(
            name: "Eugene O'Neill",
            profession: "Playwright",
            era: "1888-1953",
            condition: "Depression",
            quote: "Man is born broken. He lives by mending. The grace of God is glue.",
            biography: "Eugene O'Neill, America's first great playwright and Nobel Prize winner, battled depression throughout his life. His plays, including 'Long Day's Journey Into Night,' drew heavily from his own family's struggles with addiction and mental illness. O'Neill's work is characterized by its unflinching examination of human suffering and the search for meaning in a seemingly indifferent universe. Despite his inner turmoil, he created some of American theater's most enduring works. His ability to transform personal pain into universal art demonstrates how creative expression can be both a coping mechanism and a gift to humanity.",
            icon: "theatermasks.fill",
            colorHex: "#E74C3C",
            isHistorical: true
        ),
        
        // Ludwig van Beethoven
        MentalHealthVoice(
            name: "Ludwig van Beethoven",
            profession: "Composer",
            era: "1770-1827",
            condition: "Bipolar Disorder",
            quote: "I will seize fate by the throat; it shall certainly never wholly overcome me.",
            biography: "Beethoven experienced dramatic mood swings consistent with bipolar disorder, alternating between periods of intense creativity and deep depression. As his hearing deteriorated, his mental health struggles intensified, yet he composed some of his greatest works while completely deaf. His Ninth Symphony, created during profound isolation, stands as a testament to human resilience. Beethoven's letters reveal a man acutely aware of his suffering yet determined to transcend it through music. His life demonstrates that disability and mental illness need not silence one's voice—sometimes they amplify it, creating art that speaks across centuries.",
            icon: "music.note",
            colorHex: "#3498DB",
            isHistorical: true
        ),
        
        // Gaetano Donizetti
        MentalHealthVoice(
            name: "Gaetano Donizetti",
            profession: "Opera Composer",
            era: "1797-1848",
            condition: "Bipolar Disorder",
            quote: nil,
            biography: "Gaetano Donizetti, one of Italy's most prolific opera composers, created over 70 operas despite struggling with what historians believe was bipolar disorder. His work was characterized by periods of manic productivity followed by deep depression. Donizetti experienced profound personal tragedies, including the deaths of his wife and children, which exacerbated his mental health challenges. In his final years, his condition deteriorated significantly, yet his musical legacy endures. Works like 'Lucia di Lammermoor' and 'L'elisir d'amore' continue to move audiences worldwide. His life illustrates how creative genius can flourish even amid profound psychological and emotional suffering.",
            icon: "music.mic",
            colorHex: "#E67E22",
            isHistorical: true
        ),
        
        // Robert Schumann
        MentalHealthVoice(
            name: "Robert Schumann",
            profession: "Composer & Music Critic",
            era: "1810-1856",
            condition: "Bipolar Disorder",
            quote: "To send light into the darkness of men's hearts—such is the duty of the artist.",
            biography: "Robert Schumann's bipolar disorder profoundly influenced both his life and music. He experienced extreme creative highs where he would compose prolifically, followed by devastating lows marked by auditory hallucinations and suicidal thoughts. After a suicide attempt, he voluntarily entered an asylum where he spent his final years. Despite his struggles, Schumann created some of the Romantic era's most beautiful piano and orchestral works. His wife, Clara, was also a renowned pianist who supported him throughout his illness. Schumann's story highlights the complex relationship between mental illness and creativity, and the importance of compassionate support from loved ones.",
            icon: "pianokeys",
            colorHex: "#9B59B6",
            isHistorical: true
        ),
        
        // Leo Tolstoy
        MentalHealthVoice(
            name: "Leo Tolstoy",
            profession: "Novelist & Philosopher",
            era: "1828-1910",
            condition: "Depression",
            quote: "Everyone thinks of changing the world, but no one thinks of changing himself.",
            biography: "Leo Tolstoy, author of 'War and Peace' and 'Anna Karenina,' experienced a profound spiritual and psychological crisis in his 50s. Despite wealth, fame, and family, he was plagued by existential depression and thoughts of suicide. Tolstoy's crisis led him to question the meaning of life and seek spiritual renewal. He documented this journey in 'A Confession,' providing one of literature's most honest accounts of depression and the search for purpose. His eventual embrace of Christian anarchism and simple living represented his attempt to find meaning beyond material success. Tolstoy's struggle reminds us that depression can affect anyone, regardless of external circumstances.",
            icon: "book.closed.fill",
            colorHex: "#95A5A6",
            isHistorical: true
        ),
        
        // Vaslav Nijinsky
        MentalHealthVoice(
            name: "Vaslav Nijinsky",
            profession: "Ballet Dancer & Choreographer",
            era: "1889-1950",
            condition: "Schizophrenia",
            quote: "I am a clown of God. I am not a man, I am God in man.",
            biography: "Vaslav Nijinsky revolutionized ballet with his extraordinary athleticism and emotional expressiveness. At the height of his fame, he was diagnosed with schizophrenia in his late 20s, ending his performing career. His descent into mental illness was documented in his diary, a haunting record of a brilliant mind fragmenting. Nijinsky spent the last 30 years of his life in and out of psychiatric institutions. Despite his tragic end, his innovations in dance—including 'The Rite of Spring'—continue to influence performers today. His story underscores both the fragility of mental health and the enduring power of artistic innovation.",
            icon: "figure.dance",
            colorHex: "#E91E63",
            isHistorical: true
        ),
        
        // John Keats
        MentalHealthVoice(
            name: "John Keats",
            profession: "Romantic Poet",
            era: "1795-1821",
            condition: "Depression",
            quote: "I have been half in love with easeful Death.",
            biography: "John Keats, one of England's greatest Romantic poets, struggled with depression throughout his short life. He experienced profound losses—his mother and brother died of tuberculosis, and he himself contracted the disease at 25. Keats's poetry is infused with melancholy and an acute awareness of mortality, yet also celebrates beauty and the transcendent power of art. His letters reveal a sensitive soul grappling with despair while creating works of extraordinary beauty. Despite dying at just 25, Keats left an indelible mark on English literature. His life demonstrates that even brief candles can burn with extraordinary brightness.",
            icon: "leaf.fill",
            colorHex: "#16A085",
            isHistorical: true
        ),
        
        // Tennessee Williams
        MentalHealthVoice(
            name: "Tennessee Williams",
            profession: "Playwright",
            era: "1911-1983",
            condition: "Depression",
            quote: "Time is the longest distance between two places.",
            biography: "Tennessee Williams, creator of 'A Streetcar Named Desire' and 'The Glass Menagerie,' battled depression and anxiety throughout his life. His sister's schizophrenia and lobotomy deeply affected him, themes that echo through his work. Williams struggled with substance abuse as a way to cope with his mental health challenges. His plays are characterized by their psychological depth and exploration of human fragility. Despite his personal demons, Williams created some of American theater's most enduring characters. His work reminds us that those who understand suffering most deeply often create the most compassionate and truthful art.",
            icon: "theatermasks.fill",
            colorHex: "#8E44AD",
            isHistorical: true
        ),
        
        // Vincent van Gogh
        MentalHealthVoice(
            name: "Vincent van Gogh",
            profession: "Post-Impressionist Painter",
            era: "1853-1890",
            condition: "Bipolar Disorder",
            quote: "I put my heart and soul into my work, and I have lost my mind in the process.",
            biography: "Vincent van Gogh created some of history's most iconic paintings while battling severe mental illness, likely bipolar disorder with psychotic episodes. He experienced intense emotional highs during which he painted prolifically, followed by devastating lows marked by self-harm and hospitalization. Despite selling only one painting during his lifetime, van Gogh never stopped creating. His letters to his brother Theo reveal a man acutely aware of his suffering yet driven by an unquenchable need to express beauty. Van Gogh's legacy proves that mental illness doesn't diminish artistic vision—his unique perspective gave the world 'Starry Night' and countless other masterpieces.",
            icon: "paintpalette.fill",
            colorHex: "#F39C12",
            isHistorical: true
        ),
        
        // Isaac Newton
        MentalHealthVoice(
            name: "Isaac Newton",
            profession: "Mathematician & Physicist",
            era: "1643-1727",
            condition: "Bipolar Disorder",
            quote: "If I have seen further, it is by standing on the shoulders of giants.",
            biography: "Isaac Newton, whose laws of motion and universal gravitation revolutionized science, exhibited symptoms consistent with bipolar disorder. He experienced periods of intense focus and productivity, during which he made his greatest discoveries, alternating with episodes of paranoia, depression, and social withdrawal. Newton's obsessive nature and mood swings are well-documented in historical records. Despite these challenges, he transformed our understanding of the physical universe. His story illustrates that neurodivergence can coexist with genius, and that different ways of thinking can lead to revolutionary insights. Newton's legacy reminds us that mental health challenges don't preclude world-changing contributions.",
            icon: "atom",
            colorHex: "#2C3E50",
            isHistorical: true
        ),
        
        // Ernest Hemingway
        MentalHealthVoice(
            name: "Ernest Hemingway",
            profession: "Novelist & Journalist",
            era: "1899-1961",
            condition: "Depression & Bipolar Disorder",
            quote: "The world breaks everyone, and afterward, some are strong at the broken places.",
            biography: "Ernest Hemingway, Nobel Prize-winning author, struggled with depression and likely bipolar disorder throughout his life. His experiences in World War I left him with lasting psychological trauma. Hemingway's writing style—spare, direct, emotionally restrained—may have been his way of managing overwhelming feelings. He self-medicated with alcohol and cultivated a hyper-masculine persona, perhaps to mask his vulnerability. Despite his success, Hemingway's mental health deteriorated in his later years, exacerbated by electroconvulsive therapy. His tragic end underscores the importance of proper mental health treatment and the dangers of untreated depression, even in the most accomplished individuals.",
            icon: "text.book.closed.fill",
            colorHex: "#C0392B",
            isHistorical: true
        ),
        
        // Sylvia Plath
        MentalHealthVoice(
            name: "Sylvia Plath",
            profession: "Poet & Novelist",
            era: "1932-1963",
            condition: "Depression",
            quote: "I talk to God but the sky is empty.",
            biography: "Sylvia Plath's poetry and prose provide an unflinching look into the mind of someone living with severe depression. Her semi-autobiographical novel 'The Bell Jar' remains one of the most honest depictions of mental illness in literature. Plath made her first suicide attempt at 20 and struggled with depression throughout her adult life. Despite this, she created work of extraordinary power and beauty, including the poetry collection 'Ariel.' Her ability to transform psychological pain into art has inspired generations of writers and readers. Plath's legacy reminds us of the importance of mental health support and the devastating consequences when it's inadequate.",
            icon: "pencil.and.outline",
            colorHex: "#E74C3C",
            isHistorical: true
        ),
        
        // Michelangelo
        MentalHealthVoice(
            name: "Michelangelo",
            profession: "Renaissance Artist & Sculptor",
            era: "1475-1564",
            condition: "Depression",
            quote: "I saw the angel in the marble and carved until I set him free.",
            biography: "Michelangelo, creator of the Sistine Chapel ceiling and the statue of David, exhibited signs of depression throughout his long life. His letters reveal a man plagued by self-doubt, loneliness, and melancholy despite his extraordinary achievements. Michelangelo was known for his difficult temperament, social isolation, and obsessive work habits—possibly coping mechanisms for his inner turmoil. Yet his depression didn't prevent him from creating some of humanity's greatest art. His work demonstrates how suffering can fuel creative expression and how the drive to create can provide purpose even in the darkest times. Michelangelo's legacy spans centuries, proving that mental anguish and transcendent beauty can emerge from the same soul.",
            icon: "hammer.fill",
            colorHex: "#7F8C8D",
            isHistorical: true
        ),
        
        // Winston Churchill
        MentalHealthVoice(
            name: "Winston Churchill",
            profession: "British Prime Minister",
            era: "1874-1965",
            condition: "Depression",
            quote: "If you're going through hell, keep going.",
            biography: "Winston Churchill, who led Britain through World War II, called his depression the 'black dog' that followed him throughout life. He experienced periods of intense productivity and optimism alternating with deep melancholy. Churchill's awareness of his condition and his determination to manage it through work, painting, and writing became part of his resilience. His ability to lead during humanity's darkest hour while battling his own darkness is remarkable. Churchill's openness about his 'black dog' helped destigmatize depression, particularly among men. His life proves that mental health challenges don't disqualify someone from leadership—sometimes they provide the empathy and determination needed to guide others through crisis.",
            icon: "flag.fill",
            colorHex: "#34495E",
            isHistorical: true
        ),
        
        // Vivien Leigh
        MentalHealthVoice(
            name: "Vivien Leigh",
            profession: "Actress",
            era: "1913-1967",
            condition: "Bipolar Disorder",
            quote: nil,
            biography: "Vivien Leigh, who won two Academy Awards for 'Gone with the Wind' and 'A Streetcar Named Desire,' lived with bipolar disorder. Her condition was exacerbated by tuberculosis and the pressures of fame. Leigh experienced manic episodes during which she would become erratic and hypersexual, followed by devastating depressions. Despite these challenges, she continued to perform at the highest level, bringing complex characters to life with extraordinary emotional depth. Her husband, Laurence Olivier, supported her through many episodes, though the strain eventually contributed to their divorce. Leigh's story highlights the challenges of managing mental illness in the public eye and the courage required to continue creating despite it.",
            icon: "film.fill",
            colorHex: "#E91E63",
            isHistorical: true
        ),
        
        // Jimmy Piersall
        MentalHealthVoice(
            name: "Jimmy Piersall",
            profession: "MLB Player",
            era: "1929-2017",
            condition: "Bipolar Disorder",
            quote: "Probably the best thing that ever happened to me was going nuts. Who ever heard of Jimmy Piersall until that happened?",
            biography: "Jimmy Piersall was a talented baseball player whose on-field breakdown in 1952 led to his hospitalization and diagnosis of bipolar disorder. Rather than hiding his illness, Piersall wrote a memoir, 'Fear Strikes Out,' which became a groundbreaking film. His openness about mental illness in the 1950s, when such topics were taboo, helped countless others feel less alone. Piersall returned to baseball and had a successful 17-year career, proving that mental illness doesn't have to end one's dreams. His advocacy work and willingness to speak publicly about his experiences made him a pioneer in mental health awareness in sports.",
            icon: "baseball.fill",
            colorHex: "#27AE60",
            isHistorical: true
        ),
        
        // Patty Duke
        MentalHealthVoice(
            name: "Patty Duke",
            profession: "Actress & Mental Health Advocate",
            era: "1946-2016",
            condition: "Bipolar Disorder",
            quote: "I still have manic depression, but I'm not ashamed of it.",
            biography: "Patty Duke, who won an Oscar at 16, struggled for years with undiagnosed bipolar disorder. Her erratic behavior was often attributed to Hollywood excess, but in 1982, she was properly diagnosed and began treatment. Duke became one of the first celebrities to speak openly about bipolar disorder, writing a memoir and testifying before Congress about mental health. Her advocacy helped reduce stigma and increase understanding of the condition. Duke's willingness to be vulnerable in public gave hope to millions living with mental illness. Her legacy extends beyond her acting achievements to her role as a mental health champion who used her platform to help others.",
            icon: "star.fill",
            colorHex: "#F39C12",
            isHistorical: true
        ),
        
        // Charles Dickens
        MentalHealthVoice(
            name: "Charles Dickens",
            profession: "Novelist",
            era: "1812-1870",
            condition: "Depression",
            quote: "No one is useless in this world who lightens the burdens of another.",
            biography: "Charles Dickens, creator of 'Oliver Twist,' 'A Christmas Carol,' and 'Great Expectations,' experienced depression throughout his life, likely stemming from childhood trauma when his father was imprisoned for debt. Dickens channeled his pain into his writing, creating characters who suffered yet persevered. His novels often featured themes of social injustice, poverty, and redemption—reflecting his own struggles and his desire to create a better world. Dickens's work ethic was intense, possibly a way of managing his depression through productivity. His legacy reminds us that personal suffering can fuel compassion for others and drive us to create positive change in the world.",
            icon: "book.pages.fill",
            colorHex: "#8E44AD",
            isHistorical: true
        )
    ]
    
    // MARK: - All Voices (Historical + Modern from existing stories)
    
    var allVoices: [MentalHealthVoice] {
        historicalVoices
    }
    
    // MARK: - Bookmarking
    
    func toggleBookmark(_ voiceId: UUID) {
        if bookmarkedVoiceIds.contains(voiceId) {
            bookmarkedVoiceIds.remove(voiceId)
        } else {
            bookmarkedVoiceIds.insert(voiceId)
        }
        saveBookmarks()
    }
    
    func isBookmarked(_ voiceId: UUID) -> Bool {
        bookmarkedVoiceIds.contains(voiceId)
    }
    
    func randomVoice() -> MentalHealthVoice {
        allVoices.randomElement() ?? historicalVoices[0]
    }
    
    var bookmarkedVoices: [MentalHealthVoice] {
        allVoices.filter { bookmarkedVoiceIds.contains($0.id) }
    }
    
    // MARK: - Persistence
    
    private func saveBookmarks() {
        let ids = Array(bookmarkedVoiceIds).map { $0.uuidString }
        UserDefaults.standard.set(ids, forKey: bookmarksKey)
    }
    
    private func loadBookmarks() {
        if let ids = UserDefaults.standard.array(forKey: bookmarksKey) as? [String] {
            bookmarkedVoiceIds = Set(ids.compactMap { UUID(uuidString: $0) })
        }
    }
}
