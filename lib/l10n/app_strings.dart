class AppStrings {
  final String appName;
  final String hello;
  final String learnSomethingNew;
  final String browseCategories;
  final String browse;
  final String noFactsFound;
  final String couldNotLoad;
  final String checkConnection;
  final String tryAgain;
  final String scrollForAnother;
  final String didYouKnow;
  final String showAnswer;
  final String next;
  final String settings;
  final String profile;
  final String yourName;
  final String enterYourName;
  final String language;
  final String about;
  final String version;
  final String saveChanges;
  final String saved;
  final String welcomeTo;
  final String onboardingSubtitle;
  final String getStarted;
  final String whatsYourName;
  final String nameSubtitle;
  final String yourFirstName;
  final String continueText;
  final String chooseLanguage;
  final String moreLanguagesSoon;
  final String letsGo;
  final String all;

  const AppStrings({
    required this.appName,
    required this.hello,
    required this.learnSomethingNew,
    required this.browseCategories,
    required this.browse,
    required this.noFactsFound,
    required this.couldNotLoad,
    required this.checkConnection,
    required this.tryAgain,
    required this.scrollForAnother,
    required this.didYouKnow,
    required this.showAnswer,
    required this.next,
    required this.settings,
    required this.profile,
    required this.yourName,
    required this.enterYourName,
    required this.language,
    required this.about,
    required this.version,
    required this.saveChanges,
    required this.saved,
    required this.welcomeTo,
    required this.onboardingSubtitle,
    required this.getStarted,
    required this.whatsYourName,
    required this.nameSubtitle,
    required this.yourFirstName,
    required this.continueText,
    required this.chooseLanguage,
    required this.moreLanguagesSoon,
    required this.letsGo,
    required this.all,
  });

  static const en = AppStrings(
    appName: 'Knowly',
    hello: 'Hello',
    learnSomethingNew: 'Learn something new today',
    browseCategories: 'Browse by Category',
    browse: 'Browse',
    noFactsFound: 'No facts found',
    couldNotLoad: 'Could not load facts',
    checkConnection: 'Check your connection and try again',
    tryAgain: 'Try Again',
    scrollForAnother: 'Scroll for another question',
    didYouKnow: 'Do you know?',
    showAnswer: 'Show Answer',
    next: 'Next',
    settings: 'Settings',
    profile: 'Profile',
    yourName: 'Your name',
    enterYourName: 'Enter your name',
    language: 'Language',
    about: 'About',
    version: 'Version',
    saveChanges: 'Save Changes',
    saved: 'Saved!',
    welcomeTo: 'Welcome to\nKnowly',
    onboardingSubtitle:
        'Expand your everyday knowledge one fact at a time. Swipe through questions, reveal answers and actually learn something new.',
    getStarted: 'Get Started',
    whatsYourName: "What's your name?",
    nameSubtitle: "We'll use it to personalise your experience.",
    yourFirstName: 'Your first name',
    continueText: 'Continue',
    chooseLanguage: 'Choose your language',
    moreLanguagesSoon: 'More languages coming soon.',
    letsGo: "Let's go! 🚀",
    all: 'All',
  );

  static const sv = AppStrings(
    appName: 'Knowly',
    hello: 'Hej',
    learnSomethingNew: 'Lär dig något nytt idag',
    browseCategories: 'Välj kategori',
    browse: 'Bläddra',
    noFactsFound: 'Inga fakta hittades',
    couldNotLoad: 'Kunde inte ladda fakta',
    checkConnection: 'Kontrollera din anslutning och försök igen',
    tryAgain: 'Försök igen',
    scrollForAnother: 'Scrolla för nästa fråga',
    didYouKnow: 'Visste du?',
    showAnswer: 'Visa svar',
    next: 'Nästa',
    settings: 'Inställningar',
    profile: 'Profil',
    yourName: 'Ditt namn',
    enterYourName: 'Ange ditt namn',
    language: 'Språk',
    about: 'Om appen',
    version: 'Version',
    saveChanges: 'Spara ändringar',
    saved: 'Sparat',
    welcomeTo: 'Välkommen till\nKnowly',
    onboardingSubtitle:
        'Utöka din vardagskunskap ett faktum i taget. Svep igenom frågor, avslöja svar och lär dig något nytt.',
    getStarted: 'Kom igång',
    whatsYourName: 'Vad heter du?',
    nameSubtitle: 'Vi använder det för att anpassa din upplevelse.',
    yourFirstName: 'Ditt förnamn',
    continueText: 'Fortsätt',
    chooseLanguage: 'Välj ditt språk',
    moreLanguagesSoon: 'Fler språk kommer snart.',
    letsGo: 'Kör igång! 🚀',
    all: 'Alla',
  );

  static AppStrings of(String language) {
    switch (language) {
      case 'sv':
        return sv;
      default:
        return en;
    }
  }
}
