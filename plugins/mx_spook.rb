require 'cinch'

class MxSpook
  include Cinch::Plugin
  
  SPOOKY_SAMPLE_SIZE = 30
  # Thanks, some guy from CMU: https://www.cs.cmu.edu/~tom7/spook/
  SPOOKY_LIST = ["$400 million", "1 October", "15 May", "17 November", "3rd October", "ACLU", "ADF", "AES", "AIDS", "AIIB", "AK-47", "ALIR", 
    "ANO", "ARD", "ARN", "ASALA", "ASG", "Abu Nidal", "Abu Sayyaf", "Aceh Merdeka", "Aden-Abyan", "Ahl-e-Hadees", "Air Force One", 
    "Al-Fatah", "Al-`Asifa", "Alamo", "Albanian", "Alex Boncayao Brigade", "Alliance of Eritrean National Force", "Alliance pour la resistance democratique", 
    "Allied Democratic Forces", "American", "American Airlines", "Amn Araissi", "Arab Revolutionary Brigades", "Arab Revolutionary Council", "Area 51", 
    "Aum Shinrikyo", "Aum Supreme Truth", "Avtomat Kalasnikov", "BATF", "Babbar Khalsa", "Baghdad", "Berlin", "Bhinderanwala Tiger Force", "Black September", 
    "Brigate Rosse", "CIA", "CIRA", "CNDD", "CNRM", "CNRT", "Catholic Reaction Force", "China", "Chukaku-Ha", "Clinton", "Cocaine", "Communist", "Conseil", 
    "Cuba", "DES", "DFLP", "DNA", "Dal Khalsa", "Dayak", "Delta Airlines", "Delta Force", "Dev Sol", "Devrimci Sol", "EFF", "ELF-RC", "ESSA", "EZLN", 
    "Eastern Shan State Army", "Eiffel Tower", "Ejercito Popular Boricua", "Ejercito Popular Revolucionario", "Ellalan Force", "Eritrean", 
    "Euzkadi Ta Askatasuna", "FALINA", "FALINTIL", "FALN", "FBI", "FMLN", "FRETILIN", "FROLINA", "FSF", "Farabundo Marti", "Fatah", "Force 17", "Free Aceh", 
    "Ft. Bragg", "Ft. Meade", "GIA", "GRAPO", "George Bush", "George W Bush", "Gerakin Aceh Merdeka", "Grey Wolves", "HAMAS", "Harakat ul-Ansar", "Hawari", 
    "Hitler", "Hizb-i Wahdat", "Hizb-i-Islami", "Hizb-ul-Mujahideen", "Hizballah", "Hizbullah", "Honduras", "ICBM", "IRA", "Ikhwan-ul-Mussalmin", "Interahamwe", 
    "Iparretarrak", "Islamic", "Israel", "JKLF", "Jamaat ul-Fuqra", "Jamat-e-Islami", "Jamiat-e-Ahl-e-Hadees", "KGB", "KKK", "Kach", "Kahane Chai", "Kashmir", 
    "Kennedy", "Khaddafi", "Khalistan", "Khmer Rouge", "Komala", "Kosovo", "Kurdish", "Kurdistan", "Kuwait", "LSD", "LTTE", "La Cosa Nostra", "Lakshar-e-Taiba", 
    "Lautaro", "Legion of Doom", "Lenin", "Les mongoles", "MAPU/L", "MD5", "MI6", "MILF", "MNLF", "Macheteros", "Macheteros", "Mafia", "Maktab al-Khidamat", 
    "Manuel Rodriguez", "Marxist", "Maubere Resistance", "Mayi-Mayi", "Middle-Core", "Mohajir Qaumi", "Mong Tai", "Morazanist", "Mossad", "Mothaidda Quami", 
    "Mujahedin-e Khalq", "Myanmar", "NORAD", "NSA", "Navy", "Nazi", "Nellis Range", "Noriega", "North Korea", "Oklahoma City", "Ortega", "Osama Bin Laden", 
    "PALIPEHUTU", "PCP", "PGP", "PLO", "Pakistan", "Panama", "Pearl Harbor", "Peking", "Provos", "Qaddafi", "RC5", "RDX", "RENAMO", "RSA", "Reno", "Romania", 
    "Rule Psix", "SCUBA", "SDI", "SEAL Team 6", "SHA", "SWAT", "Saddam Hussein", "Saheed Khalsa", "Scientology", "Semtex", "Serbian", "Shora-e-Jehad", 
    "Sivi Vukovi", "South Africa", "Soviet ", "Steyr", "Students of the Engineer", "TEMPEST", "TNT", "Tal Al Za'atar", "Talaa' al-Fateh", "Tamil Eelam", 
    "Teamsters", "Terra Lliure", "Treasury", "Tupac Amaru", "U-235", "US Airways", "Uzi", "Waco", "White House", "World Trade Center", "Zapatistas", "airframe", 
    "airport", "al-Gama'at al-Islamiyya", "al-Jihad", "al-Qa'ida", "algorithm", "amatol", "ambush", "ambush", "ammo", "ammunition", "anonymous", "anti-tank", 
    "archives", "armada", "armor", "armor-piercing", "arms", "arrangements", "assassinate", "assassination", "assassination", "assault", "atomic bomb", 
    "bank account", "biological", "blowfish", "bomb", "bomb", "boobytrap", "border", "c4", "camera", "carnivore", "charcoal", "chemical", "child pornography", 
    "chinese", "class struggle", "claymore", "cocaine", "codebook", "colonel", "commando", "composition b", "conspiracy", "constitution", "cordite", "corporate", 
    "corrupt", "council", "counter-intelligence", "crack-cocaine", "cracking", "cray", "credit card", "cryptographic", "czar", "d-day", "data haven", 
    "defcon", "defenses", "democratie", "detcord", "detonate", "detonators", "dictionary", "disruption", "divers", "doctrine", "domestic", "doomsday", 
    "double agent", "e-bola", "echelon", "efnet", "embassy", "embassy", "embassy", "empire", "encrypt", "enigma", "explosion", "explosive", "faction", 
    "fertilizer", "fissionable", "flight 800", "freedom", "freemasons", "genetic", "gold bullion", "government", "grenades", "guns", "hack", "harbor", 
    "heroin", "hijack", "hostage", "hostages", "hydrogen bomb", "illuminati", "impulse", "incendiaries", "infiltration", "infosec", "infrastructure", 
    "initiators", "insurgent", "intel", "international", "internet worm", "interpol", "jihad", "kamikazi", "kampuchea", "kibo", "kill", "kill", "kill", "kill", 
    "launch codes", "lead azide", "lead styphante", "liberate", "liberation", "limousine", "lockpick", "loyalist", "main charge", "marijuana", "martyr", 
    "maverick", "mercury fulminate", "microfiche", "microfilm", "minefield", "mines", "motorcade", "motorola", "mouvement", "munitions", "napalm", "nationalist", 
    "nitric acid", "nitrocellulose", "nuclear", "oppressed", "orthodox", "password", "picric acid", "pipe-bomb", "plague", "platter charge", "plutonium", 
    "plutonium", "policy", "political", "pre-teen", "president", "president", "primers", "private key", "propaganda", "psyops", "public key", 
    "pulse detonation engine", "radar", "rail gun", "rebel", "remailer", "resistance", "revolucionario", "rijndael", "robotic", "rockets", "root-servers.net", 
    "rubella", "salt peter", "sanctions", "satelliate", "satellite", "satellite phone", "secret", "secret key", "secret service", "secure", "security", 
    "sequence", "shaped charge", "smallpox", "smuggle", "sniper", "sniper", "socialist", "space station", "spy", "steganography", "strategic", "submarine",
    "subsonic", "suicide", "suicide bombing", "sulfur", "supercomputer", "supersonic", "surveillance", "teflon bullets", "terminate", "terrorist", 
    "theater missile defense", "thermite", "timers", "tunneling", "undercover", "undernet", "uranium", "virus", "warfare", "warrant", "weapons", 
    "white noise generator", "wiretap", "zenith"]
  
  listen_to :channel
  def listen(m)
    match = /M-x spook\b/.match(m.message)
    if match
      spooky_message = SPOOKY_LIST.sample(SPOOKY_SAMPLE_SIZE).join(" ")
      m.reply spooky_message
    end
  end
end

