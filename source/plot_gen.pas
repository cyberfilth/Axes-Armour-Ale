(* Generate names and plot elements *)

unit plot_gen;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, dos, player_stats;

const
  DayStr: array[0..6] of string =
    ('Fastday', 'Onesday', 'Twosday', 'Frogday', 'Hawksday', 'Feastday', 'Marketday');
  MonthStr: array[1..12] of string =
    ('Mistmon', 'Brittleice', 'Windmon', 'Gunther', 'Sweetbriar', 'Greenling',
    'Frogsong', 'Sunmon', 'Southflight',
    'Harvestmoon', 'Ghostmoon', 'Stormlight');

var
  playerName, playerTitle, trollDate: string;
  Year, Month, Day, WDay: word;
  titles: array[0..108] of string = ('Abominable', 'Amorous',
    'Afflicted', 'Ailing', 'Breathless', 'Broken', 'Bullish', 'Craggy',
    'Bearded', 'Bony', 'Beastly', 'Drunken', 'Bitter', 'Fetid', 'Fierce',
    'Fiery', 'Bold', 'Filthy', 'Craven', 'Fishy', 'Crooked', 'Flexible',
    'Crusty', 'Forgetful', 'Brutal', 'Foul', 'Disturbed', 'Forgettable',
    'Burly', 'Fragrant', 'Dramatic', 'Frisky', 'Gallant', 'Green',
    'Delectable', 'Cold', 'Grey', 'Cursed', 'Grumpy', 'Grubby', 'Dark',
    'Hairless', 'Hairy', 'Heathen', 'Defiant', 'Jaded', 'Knobbly',
    'Indecent', 'Detestable', 'Dreaded', 'Jumpy', 'Aromatic', 'Wrinkled',
    'Wild', 'Unsmiling', 'Warty', 'Towering', 'Valiant', 'Sweaty',
    'Sour', 'Vain', 'Unseemly', 'Swarthy', 'Tragic', 'Strange', 'Stout',
    'Stony', 'Stormy', 'Shameless', 'Stalwart', 'Quiet', 'Sleepy',
    'Pure', 'Prickly', 'Scarred', 'Pimply', 'Pale', 'Savage', 'Ornate',
    'Simple', 'Silly', 'Salty', 'Rotund', 'Miserable', 'Scrappy',
    'Ragged', 'Lanky', 'Scowly', 'Hardy', 'Harsh', 'Gruesome', 'Gross',
    'Grisly', 'Goodly', 'Gloomy', 'Nocturnal', 'Fair', 'Chiseled',
    'Insatiable', 'Destructive', 'Dreadful', 'Musical', 'Frightful',
    'Oily', 'Rascal', 'Remorseless', 'Squinty', 'Silvery', 'Thirsty');

  firstSyllable: array[0..73] of
  string = ('A', 'Ag', 'Ar', 'Ara', 'Anu', 'Bal', 'Bil', 'Boro',
    'Bern', 'Bra', 'Cas', 'Cere', 'Co', 'Con', 'Cor', 'Dag', 'Doo',
    'Elen', 'El', 'En', 'Eo', 'Faf', 'Fan', 'Fara', 'Fre', 'Fro',
    'Ga', 'Gala', 'Has', 'He', 'Heim', 'Ho', 'Isil', 'In', 'Ini',
    'Is', 'Ka', 'Kuo', 'Lance', 'Lo', 'Ma', 'Mag', 'Mi', 'Mo', 'Moon',
    'Mor', 'Mora', 'Nin', 'O', 'Obi', 'Og', 'Pelli', 'Por', 'Ran',
    'Rud', 'Sam', 'She', 'Sheel', 'Shin', 'Shog', 'Son', 'Sur', 'Theo',
    'Tho', 'Tris', 'U', 'Uh', 'Ul', 'Vap', 'Vish', 'Vor', 'Ya', 'Yo', 'Yyr');

  secondSyllable: array[0..62] of
  string = ('ba', 'bis', 'bo', 'bus', 'da', 'dal', 'dagz', 'den',
    'di', 'dil', 'dinn', 'do', 'dor', 'dra', 'dur', 'gi', 'gauble',
    'gen', 'glum', 'go', 'gorn', 'goth', 'had', 'hard', 'is', 'karrl',
    'ki', 'koon', 'ku', 'lad', 'ler', 'li', 'lot', 'ma', 'man', 'mir',
    'mus', 'nan', 'ni', 'nor', 'nu', 'pian', 'ra', 'rakh', 'ric',
    'rin', 'rum', 'rus', 'rut', 'sekh', 'sha', 'thos', 'thur', 'toa',
    'tu', 'tur', 'tred', 'varl', 'wain', 'wan', 'win', 'wise', 'ya');

  elvenName: array[0..885] of
  string = ('Aarall', 'Abiala', 'Acanos', 'Acarnar', 'Adali', 'Adari',
    'Adarore', 'Addin', 'Aderiel', 'Adius', 'Agrae', 'Aitese', 'Alane',
    'Alar', 'Alaril', 'Alasar', 'Aldas', 'Aler', 'Alerin', 'Alesan',
    'Alia', 'Aliamer', 'Aliani', 'Alina', 'Alisa', 'Aloria', 'Alveler',
    'Alys', 'Amar', 'Amarid', 'Ambeya', 'Amendi', 'Amera', 'Amina',
    'Ampeto', 'Anasesh', 'Ancar', 'Ando', 'Anila', 'Anos', 'Aranar',
    'Aranil', 'Ardey', 'Arel', 'Aren', 'Arenan', 'Ariania', 'Arica',
    'Arili', 'Arilyn', 'Arin', 'Arina', 'Arinik', 'Arogar', 'Arokena',
    'Aron', 'Arosar', 'Arra', 'Aruz', 'Asela', 'Asoniri', 'Aurin',
    'Auseri', 'Avala', 'Avaran', 'Aven', 'Avialar', 'Baen', 'Balar',
    'Balas', 'Baliar', 'Balic', 'Balog', 'Balt', 'Balyn', 'Bandan',
    'Bania', 'Banill', 'Banin', 'Barbarto', 'Baren', 'Barisla', 'Barro',
    'Baselan', 'Baynar', 'Bazar', 'Belar', 'Bele', 'Beli', 'Belix',
    'Bengo', 'Benik', 'Beniko', 'Benin', 'Beralli', 'Berand', 'Beranti',
    'Bergoan', 'Besar', 'Bestel', 'Beti', 'Betton', 'Beust', 'Birri',
    'Bogdan', 'Bolegro', 'Bonda', 'Boneas', 'Bora', 'Boras', 'Borel',
    'Borial', 'Borst', 'Bosovan', 'Brannon', 'Brir', 'Buen', 'Bynta',
    'Cadryn', 'Cail', 'Calari', 'Calia', 'Calica', 'Calinila', 'Camedna',
    'Camin', 'Caminis', 'Caneleyr', 'Caniso', 'Canseri', 'Canzess',
    'Cara', 'Caresal', 'Carike', 'Cariri', 'Cariso', 'Caros', 'Carriva',
    'Carst', 'Carth', 'Casalor', 'Cashar', 'Cashi', 'Caso', 'Cason',
    'Cass', 'Caurio', 'Cavar', 'Cavi', 'Celan', 'Celas', 'Celia',
    'Celicu', 'Celini', 'Cenos', 'Ceretel', 'Cerian', 'Cesenia',
    'Ceshariv', 'Cetal', 'Cevau', 'Chaen', 'Chakin', 'Chaliar', 'Chana',
    'Chanus', 'Charane', 'Chardina', 'Chari', 'Chast', 'Chaun', 'Chayni',
    'Chele', 'Chergari', 'Cherin', 'Cheth', 'Chevute', 'Chona', 'Chtene',
    'Ciana', 'Ciavi', 'Cilin', 'Cindali', 'Ciusi', 'Corus', 'Cusambe',
    'Daelas', 'Dalar', 'Dalen', 'Dameta', 'Danari', 'Dandiau',
    'Danereti', 'Danica', 'Danius', 'Dara', 'Daric', 'Darit', 'Darril',
    'Dason', 'Daus', 'Daveyni', 'Daymi', 'Denni', 'Derin', 'Dier',
    'Dinel', 'Dinimay', 'Dona', 'Doni', 'Donila', 'Dorich', 'Dorin',
    'Dornet', 'Doshand', 'Doson', 'Dushan', 'Duski', 'Dusor', 'Edanda',
    'Edda', 'Einar', 'Elamah', 'Elanda', 'Elanine', 'Elarin', 'Elarivi',
    'Elasar', 'Eleri', 'Elian', 'Eliana', 'Eliar', 'Elic', 'Elini',
    'Elinus', 'Ellera', 'Ellia', 'Elosene', 'Elsi', 'Emar', 'Emarinte',
    'Emedea', 'Eminial', 'Emonani', 'Erevi', 'Erik', 'Erinak', 'Erivu',
    'Erko', 'Erlidan', 'Esarn', 'Estel', 'Evelosana', 'Evut', 'Ewal',
    'Facan', 'Falal', 'Falani', 'Famela', 'Famial', 'Fana', 'Fanau',
    'Fandar', 'Fara', 'Farar', 'Farele', 'Faril', 'Farini', 'Faros',
    'Fauane', 'Favan', 'Favus', 'Fawlre', 'Fedau', 'Felani', 'Felldi',
    'Fellonar', 'Fenaran', 'Fendor', 'Fenki', 'Fera', 'Feria', 'Ferius',
    'Ferrido', 'Ferza', 'Findi', 'Galani', 'Galarel', 'Galban', 'Galic',
    'Ganar', 'Ganil', 'Ganiv', 'Ganyl', 'Garath', 'Garer', 'Garesk',
    'Garin', 'Garita', 'Garius', 'Garus', 'Gasto', 'Gausa', 'Gelani',
    'Genas', 'Genia', 'Genna', 'Gensha', 'Gerikos', 'Ginel', 'Gorall',
    'Grale', 'Granar', 'Grari', 'Grart', 'Grauxe', 'Greza', 'Griane',
    'Griele', 'Grifen', 'Grik', 'Grinos', 'Griss', 'Gunar', 'Gushani',
    'Hadar', 'Hadariar', 'Haeran', 'Hahius', 'Halda', 'Hali', 'Hanan',
    'Hanar', 'Handar', 'Handis', 'Hano', 'Hanthu', 'Haregen', 'Hareta',
    'Hari', 'Harias', 'Haric', 'Haril', 'Harir', 'Hars', 'Harta',
    'Harth', 'Hasolar', 'Hasti', 'Hastt', 'Hauri', 'Havani', 'Hayl',
    'Helav', 'Helia', 'Helik', 'Henir', 'Hesken', 'Hest', 'Hestel',
    'Hettoneri', 'Heyki', 'Holaus', 'Honte', 'Horel', 'Horrin', 'Hukalo',
    'Hus', 'Idara', 'Idele', 'Illan', 'Illar', 'Irga', 'Irnaz', 'Isar',
    'Iseli', 'Ishton', 'Iskin', 'Isonda', 'Isorol', 'Ister', 'Isterd',
    'Istev', 'Istoria', 'Jacaden', 'Jala', 'Jalaras', 'Jalerta',
    'Jalir', 'Jaliuli', 'Jangan', 'Janius', 'Janyno', 'Jareta', 'Jari',
    'Jaris', 'Jarte', 'Jasaveri', 'Jase', 'Jauna', 'Javal', 'Javer',
    'Jax', 'Jelamia', 'Jogdali', 'Jonan', 'Jonania', 'Jondi', 'Jonel',
    'Jonfi', 'Jonic', 'Jons', 'Jorar', 'Jorel', 'Joren', 'Joric',
    'Jorin', 'Jorint', 'Jorona', 'Josha', 'Josto', 'Kaiella', 'Kalonen',
    'Kamar', 'Kanaran', 'Kano', 'Karedan', 'Kareg', 'Karin', 'Karina',
    'Kedin', 'Kelar', 'Kelarar', 'Kelin', 'Kenar', 'Kenisa', 'Kerai',
    'Kerdic', 'Kerid', 'Kleri', 'Kobet', 'Kric', 'Kynara', 'Kynersa',
    'Laeric', 'Lali', 'Lanan', 'Lanar', 'Lanic', 'Lankaur', 'Lanust',
    'Lar', 'Laras', 'Larel', 'Lari', 'Laria', 'Larin', 'Larnus',
    'Leau', 'Lela', 'Lelina', 'Lenasa', 'Lenax', 'Lerte', 'Leshof',
    'Lestous', 'Liarol', 'Linaus', 'Linia', 'Llanos', 'Llaris', 'Llorinar',
    'Lolarere', 'Lolas', 'Lonara', 'Loneri', 'Loras', 'Loria', 'Lorker',
    'Lorro', 'Lorson', 'Luicha', 'Luil', 'Lukis', 'Lukovi', 'Lurinea',
    'Luron', 'Lushani', 'Luso', 'Luto', 'Lyna', 'Madil', 'Maisel',
    'Mala', 'Malar', 'Malin', 'Mamesi', 'Manak', 'Manc', 'Mani',
    'Maniard', 'Mano', 'Manuss', 'Maral', 'Mararo', 'Mari', 'Marid',
    'Marini', 'Maron', 'Marton', 'Marya', 'Masel', 'Masonar', 'Mauni',
    'Maus', 'Mautis', 'Mayssa', 'Medeiro', 'Melle', 'Menam', 'Merga',
    'Merinis', 'Meriu', 'Meson', 'Meteri', 'Meyr', 'Minerde', 'Mirar',
    'Moguret', 'Monan', 'Mongar', 'Morill', 'Morrder', 'Mueron',
    'Mukiar', 'Munic', 'Muraris', 'Muren', 'Murossi', 'Muschu', 'Musor',
    'Myanero', 'Mykeron', 'Myr', 'Nabail', 'Nalow', 'Nedan', 'Nelara',
    'Nelel', 'Nellin', 'Neni', 'Nereya', 'Neri', 'Neric', 'Nerin',
    'Nerissar', 'Neronir', 'Nesar', 'Netha', 'Neyn', 'Nich', 'Nullera',
    'Nuschari', 'Nyal', 'Odiam', 'Olazar', 'Olena', 'Olin', 'Olstall',
    'Orori', 'Oryn', 'Osale', 'Osando', 'Osar', 'Paglas', 'Pahus',
    'Palia', 'Palik', 'Pandi', 'Parano', 'Pardo', 'Parea', 'Parichi',
    'Pasil', 'Pasth', 'Pela', 'Pelari', 'Penyn', 'Pere', 'Periar',
    'Perin', 'Petas', 'Peyrnu', 'Phera', 'Phina', 'Praiso', 'Rabalo',
    'Ralian', 'Ralich', 'Ralli', 'Ramar', 'Ramosen', 'Ranen', 'Raria',
    'Raros', 'Rars', 'Rarzar', 'Rela', 'Rellaron', 'Restone', 'Rinan',
    'Rindela', 'Rinergan', 'Rinian', 'Roda', 'Rogar', 'Roich', 'Rokon',
    'Rolan', 'Ronen', 'Rones', 'Roraff', 'Rorich', 'Rosar', 'Roschi',
    'Rosini', 'Rumert', 'Runia', 'Rusana', 'Rusha', 'Russh', 'Rusthe',
    'Ryarta', 'Saba', 'Saesh', 'Salakero', 'Salani', 'Salar', 'Saliar',
    'Sanar', 'Sandor', 'Sanelita', 'Saninar', 'Sano', 'Sanshin',
    'Sanza', 'Sarato', 'Sarene', 'Sarensen', 'Sarici', 'Sarin', 'Sarori',
    'Sarrvarin', 'Sarve', 'Sasena', 'Scane', 'Scarin', 'Scena', 'Sedar',
    'Sedes', 'Selar', 'Selen', 'Selia', 'Selian', 'Selin', 'Sella',
    'Sellino', 'Senan', 'Senaro', 'Senova', 'Senten', 'Serar', 'Serel',
    'Seren', 'Serena', 'Serian', 'Serica', 'Serine', 'Serle',
    'Serondala', 'Serreri', 'Setari', 'Setena', 'Setoni', 'Seynara',
    'Shan', 'Shana', 'Shani', 'Shannet', 'Shero', 'Shir', 'Shori',
    'Shorik', 'Shosa', 'Siadi', 'Siale', 'Siari', 'Sideni', 'Siderto',
    'Sigak', 'Silison', 'Silus', 'Sinad', 'Sindalar', 'Sinera', 'Sinian',
    'Sinir', 'Sinolax', 'Sinov', 'Sinyas', 'Sisar', 'Sisela', 'Solia',
    'Sorin', 'Spella', 'Stamma', 'Stanid', 'Stardan', 'Stari', 'Staron',
    'Stau', 'Staus', 'Steland', 'Stele', 'Stelo', 'Stelos', 'Stena',
    'Stenera', 'Stenfon', 'Steni', 'Stenia', 'Sterba', 'Sterian',
    'Steris', 'Stero', 'Stich', 'Stila', 'Stino', 'Stolan', 'Ston',
    'Stona', 'Stoss', 'Sturo', 'Sulare', 'Svar', 'Svari', 'Svela',
    'Sviaro', 'Svini', 'Syala', 'Syavan', 'Sysan', 'Tahlis', 'Tala',
    'Talia', 'Talian', 'Tanant', 'Tannto', 'Taras', 'Tasal', 'Tasho',
    'Tasoe', 'Taston', 'Tavid', 'Taylini', 'Tela', 'Telar', 'Telari',
    'Telian', 'Telif', 'Teline', 'Tenana', 'Tenar', 'Tenasa', 'Tendra',
    'Teniu', 'Tereal', 'Terera', 'Terin', 'Tetan', 'Teutani', 'Thala',
    'Thale', 'Thalia', 'Thamar', 'Tharanie', 'Tharen', 'Thargo',
    'Thari', 'Thasar', 'Thato', 'Thauin', 'Thave', 'Thenia', 'Theren',
    'Thina', 'Thish', 'Tho', 'Thogar', 'Thond', 'Thorlin', 'Togar',
    'Tonen', 'Toninus', 'Tontus', 'Torik', 'Torinca', 'Torok', 'Treg',
    'Tress', 'Triana', 'Trileni', 'Trinea', 'Trius', 'Tunis', 'Tusha',
    'Urilla', 'Valarlit', 'Valich', 'Vampe', 'Vaneta', 'Vani', 'Vanicha',
    'Vanil', 'Vanyan', 'Varas', 'Varia', 'Varin', 'Varit', 'Varta',
    'Vasan', 'Vasela', 'Vasharo', 'Vashtus', 'Vasinin', 'Vayn', 'Vazan',
    'Vela', 'Verana', 'Veres', 'Verngen', 'Veron', 'Veyn', 'Vezos',
    'Vien', 'Viera', 'Vili', 'Vinensk', 'Vinian', 'Vinus', 'Viopal',
    'Virone', 'Vitaloa', 'Vius', 'Viusoni', 'Vivar', 'Viviric',
    'Voracas', 'Wari', 'Waron', 'Werana', 'Wesa', 'Weyri', 'Willi',
    'Wimina', 'Windolen', 'Winiba', 'Winso', 'Witma', 'Wylion', 'Yari',
    'Yogor', 'Zaal', 'Zarena', 'Ziali', 'Zira', 'Terix', 'Razal',
    'Lunella', 'Seron', 'Tharene', 'Nellino', 'Dushani', 'Raliar', 'Valaras', 'Liaro');

  dwarvenName: array[0..109] of
  string = ('Ailgor', 'Ainion', 'Alon', 'Alvion', 'Amur', 'Andol',
    'Argli', 'Arol', 'Artil', 'Artor', 'Avli', 'Balan', 'Balor',
    'Bamon', 'Bandiol', 'Baril', 'Baron', 'Baviol', 'Bavor', 'Bodol',
    'Bogrion', 'Bolvol', 'Bondiol', 'Borli', 'Bortur', 'Bovan', 'Dalin',
    'Dalon', 'Dalvol', 'Damli', 'Dandil', 'Dargol', 'Dartion', 'Dartol',
    'Dilgli', 'Dilgol', 'Dilin', 'Dilvir', 'Dinan', 'Dirgli', 'Dithur',
    'Dogion', 'Dogron', 'Dogror', 'Domin', 'Domir', 'Dondan', 'Dondli',
    'Dorgor', 'Doror', 'Dradan', 'Drartli', 'Drartol', 'Drartor',
    'Drathiol', 'Dravil', 'Dravon', 'Dulon', 'Durgion', 'Durin',
    'Duror', 'Durtin', 'Durtiol', 'Duviol', 'Galvan', 'Ganion',
    'Gathion', 'Gidir', 'Gilvin', 'Gilvion', 'Gilvur', 'Gindil',
    'Givion', 'Glodil', 'Glolgol', 'Glolol', 'Glolvan', 'Glonir',
    'Gloror', 'Glothiol', 'Glothol', 'Glothur', 'Glovion', 'Madin',
    'Maliol', 'Mandion', 'Manil', 'Margin', 'Martion', 'Mathiol',
    'Mavan', 'Mavan', 'Ralan', 'Ralli', 'Ramli', 'Ranin', 'Rargin',
    'Rarli', 'Rarol', 'Rartil', 'Rundin', 'Runin', 'Rurgir', 'Ruril',
    'Rurir', 'Ruvil', 'Ruvli', 'Thogin', 'Thogrur', 'Thondir');

  clanFirst: array[0..17] of string = ('Iron', 'Rock', 'Dark', 'War',
    'Grim', 'Rune', 'Storm', 'Frost', 'Thunder', 'Bright', 'Blood',
    'Grey', 'Stone', 'Bronze', 'Silver', 'Bone', 'Mist', 'Ice');

  clanSecond: array[0..19] of
  string = ('Axe', 'Hammer', 'Anvil', 'Smith', 'Forge', 'Beard',
    'Shield', 'Biter', 'Bane', 'Weaver', 'Mage', 'Spear', 'Seeker',
    'Sword', 'Crafter', 'Breaker', 'Born', 'Helm', 'Hold', 'Fist');

  elvenHomea: array[0..13] of
  string = ('the Vale of', 'the Whispering Forest of', 'the forest of',
    'the white peaks of', 'the woods of', 'the Cinderlands of',
    'the Frostspike of', 'the snow pass of', 'the green fortress of',
    'the Waterways of', 'the sorrowful streams of', 'the Whispering Glade of',
    'the Hidden Spires of', 'the Shimmering of');

  elvenHomeb: array[0..42] of
  string = ('Felamae', 'Lorrom', 'Anorel', 'Weneres', 'Rathel',
    'Lasbreg-Dwyr', 'Renamar', 'Sarriel', 'Vius', 'Viusand', 'Ethgal',
    'Renfin', 'Syldar', 'Thrantor', 'Paceledrel', 'Borntae', 'Mai-Ionla',
    'Marrion', 'Thorndal', 'Ladkur', 'Imorvo', 'Rescir', 'Godan',
    'Vadan', 'Daggil', 'Saner', 'Evnall', 'Lexa', 'Alta', 'Lorandwyr',
    'Saand-Riel', 'Mardír', 'Dorril', 'Thallor', 'Wingdal', 'Duil',
    'Glanduil', 'Iliphar', 'Ilrune', 'Saleh', 'Urijyre', 'Inamys', 'Caiwraek');

  villageName: array[0..11] of
  string = ('PigSpit', 'FootRot', 'MudLands', 'SquelchBottom',
    'DungMould', 'Belchford', 'Goatstone', 'Kloggington', 'Ordure Field',
    'Clagstone', 'Dogmire', 'Klart');

  aquilonianMaleFirst: array[0..187] of
  string = ('Abant', 'Abantiad', 'Ac', 'Acris', 'Act', 'Alc', 'Alcid',
    'Am', 'Andr', 'Andr', 'Arct', 'Arct', 'Arp', 'Asclep', 'Atab',
    'Atab', 'Attal', 'Auf', 'Aufid', 'Bal', 'Balend', 'Barr', 'Barr',
    'Bor', 'Call', 'Call', 'Cenw', 'Cenw', 'Clad', 'Clad', 'Dard',
    'Dard', 'Dec', 'Decual', 'Edr', 'Elig', 'Elig', 'Em', 'Er', 'Erast',
    'Fabr', 'Fabr', 'Glac', 'Glac', 'Gr', 'Grat', 'Grat', 'Guil',
    'Guil', 'Hil', 'Hilar', 'Inach', 'Iph', 'Kl', 'Kost', 'Kost',
    'Laud', 'Laud', 'Lavon', 'Lib', 'Lorm', 'Lorm', 'Luc', 'Metab',
    'Mez', 'Mezent', 'Ner', 'Num', 'Octa', 'Octa', 'Octav', 'Pallant',
    'Parn', 'Parn', 'Periph', 'Periphet', 'Prosp', 'Rin', 'Sept',
    'Sept', 'Sor', 'Soract', 'Th', 'Thor', 'Thor', 'Tib', 'Tiber',
    'Val', 'Vict', 'Vict', 'Victor', 'Viler', 'Zav', 'Zor', 'Acast',
    'Ach', 'Acrision', 'Aeg', 'Aegid', 'Al', 'Amalr', 'Amul', 'Amul',
    'Andron', 'Ang', 'Arar', 'Arar', 'Ascl', 'Ascl', 'Atabul', 'Att',
    'Attel', 'Aur', 'Aurel', 'Ball', 'Ball', 'Baracc', 'Bel', 'Cadm',
    'Cadm', 'Carn', 'Carn', 'Ceph', 'Ceph', 'Codr', 'Codr', 'Dam',
    'Dex', 'Dexith', 'Drag', 'Drag', 'El', 'Emil', 'Emil', 'Ep',
    'Favon', 'Flav', 'Flav', 'Ful', 'Gl', 'Gonz', 'Gonz', 'Grom',
    'Grom', 'Hor', 'Horat', 'Il', 'Kest', 'Kest', 'Klaud', 'Kr',
    'Krel', 'Krel', 'Lar', 'Leon', 'Leon', 'Lor', 'Marin', 'Merc',
    'Merc', 'Met', 'Mod', 'Modest', 'Nol', 'Numed', 'Orast', 'Pall',
    'Pall', 'Parnass', 'Publ', 'Publ', 'Rig', 'Ruf', 'Septim', 'Serv',
    'Serv', 'Sur', 'Thesp', 'Troc', 'Troc', 'Tul', 'Valann', 'Valer',
    'Vil', 'Volm', 'Volm', 'Volman', 'Zet');

  aquilonianMaleLast: array[0..99] of
  string = ('a', 'i', 'o', 'as', 'el', 'er', 'es', 'ic', 'in', 'io',
    'is', 'on', 'os', 'us', 'yc', 'ago', 'ald', 'ana', 'ana', 'eas',
    'ell', 'ell', 'eri', 'eus', 'eus', 'ian', 'ias', 'ias', 'ion',
    'ius', 'ius', 'uis', 'ulf', 'ulk', 'ura', 'abus', 'acus', 'ades',
    'aeon', 'aeus', 'aime', 'alin', 'alle', 'alus', 'alvi', 'anus',
    'ares', 'aris', 'elio', 'elis', 'elus', 'erus', 'etes', 'icus',
    'ides', 'idos', 'idus', 'imer', 'imus', 'ocer', 'omel', 'orin',
    'orus', 'ulio', 'ulus', 'accus', 'achus', 'actus', 'alion', 'alric',
    'annus', 'arras', 'assus', 'astus', 'atian', 'atius', 'avian',
    'avius', 'eades', 'elius', 'endin', 'entius', 'epius', 'ercer',
    'erias', 'erius', 'estus', 'iades', 'igius', 'ilius', 'orian',
    'ostas', 'arioin', 'audius', 'edides', 'ervius', 'espius', 'itheus',
    'onicus', 'antides');

  aquilonianFemaleFirst: array[0..97] of
  string = ('Adam', 'Aeg', 'Al', 'Alb', 'Albion', 'Alc', 'Alcim',
    'Anger', 'Arac', 'Arac', 'Aracel', 'Arian', 'Ariann', 'Balb',
    'Bith', 'Bolb', 'Cair', 'Cairist', 'Call', 'Card', 'Carm', 'Cat',
    'Dac', 'Dac', 'Dam', 'Damian', 'Deid', 'Deidam', 'Dev', 'Don',
    'Ech', 'Echidn', 'Elv', 'Elv', 'Em', 'Ep', 'Epion', 'Euandr',
    'Euryd', 'Fel', 'Fluon', 'Gal', 'Gal', 'Galat', 'Gl', 'Gryn',
    'Halac', 'Hec', 'Hecub', 'Heroph', 'Hor', 'Hor', 'Horac', 'Il',
    'In', 'Iph', 'Kal', 'Kal', 'Korn', 'Lam', 'Lar', 'Lel', 'Let',
    'Lev', 'Levan', 'Lor', 'Lor', 'Lorell', 'Malv', 'Mar', 'Mat',
    'Mess', 'Naut', 'Nel', 'Nol', 'Nyd', 'Pall', 'Pan', 'Pasith',
    'Pell', 'Ph', 'Ren', 'Rh', 'Ros', 'Ros', 'Sal', 'Salv', 'Sec',
    'Suad', 'Teth', 'Tim', 'Tryph', 'Val', 'Vern', 'Vig', 'Vimand', 'Vir', 'Zel');

  aquilonianFemaleLast: array[0..99] of
  string = ('a', 'e', 'ea', 'ia', 'ia', 'ya', 'ys', 'ana', 'ana',
    'are', 'are', 'ata', 'ata', 'ede', 'ede', 'eia', 'eia', 'eis',
    'eis', 'ele', 'ele', 'ena', 'ena', 'ene', 'ene', 'era', 'era',
    'eta', 'ice', 'ice', 'ida', 'ida', 'ige', 'ige', 'ile', 'ina',
    'ina', 'ita', 'ita', 'ona', 'ona', 'ope', 'ope', 'ota', 'ota',
    'uba', 'uba', 'uta', 'uta', 'abel', 'abel', 'acia', 'acia', 'anne',
    'anne', 'atea', 'atea', 'auce', 'auce', 'elia', 'elia', 'elle',
    'elle', 'enta', 'enta', 'eria', 'eria', 'iana', 'iana', 'idna',
    'idna', 'ilia', 'ilia', 'ilis', 'ilis', 'iona', 'iona', 'iona',
    'iona', 'ione', 'ione', 'iope', 'iope', 'ista', 'ista', 'onia',
    'onia', 'unda', 'unda', 'ynia', 'ynia', 'aedra', 'ameia', 'amina',
    'andra', 'antia', 'autia', 'imede', 'inome', 'ithea');

(* Generate a human name for the player *)
procedure generateHumanName;
(* Generate an Elven name for the player *)
procedure generateElfName;
(* Generate a Dwarven name for the player *)
procedure generateDwarfName;
(* Generate Dwarven clan name *)
procedure generateClanName;
(* Generate name of an Elven home *)
function elvenTown: string;
(* Generate name of small village *)
function smallVillage: string;
(* Generate a title or honorfic for the player *)
procedure generateTitle;
(* Get the current date and display it in the in-game calendar *)
procedure getTrollDate;

implementation

procedure generateHumanName;
var
  a, b: byte;
begin
  a := Random(73);
  b := Random(62);
  playerName := firstSyllable[a] + secondSyllable[b];
  generateTitle;
end;

procedure generateElfName;
begin
  playerName := elvenName[Random(885)];
  generateTitle;
end;

procedure generateDwarfName;
begin
  playerName := dwarvenName[Random(109)];
  generateTitle;
end;

procedure generateClanName;
var
  a, b: byte;
begin
  a := Random(17);
  b := Random(19);
  player_stats.clanName := clanFirst[a] + clanSecond[b];
end;

function elvenTown: string;
var
  a, b: byte;
begin
  a := Random(13);
  b := Random(42);
  Result := elvenHomea[a] + ' ' + elvenHomeb[b];
end;

function smallVillage: string;
var
  a: byte;
begin
  a := Random(11);
  Result := villageName[a];
end;

procedure generateTitle;
begin
  playerTitle := titles[Random(108)];
end;

procedure getTrollDate;
begin
  Year := 0;
  Month := 0;
  Day := 0;
  WDay := 0;
  trollDate := '';
  GetDate(Year, Month, Day, WDay);
  trollDate := DayStr[WDay] + ', the ' + IntToStr(Day);
  (* Add suffix *)
  if (Day = 11) or (Day = 12) or (Day = 13) then
    trollDate := trollDate + 'th'
  else if (Day mod 10 = 1) then
    trollDate := trollDate + 'st'
  else if (Day mod 10 = 2) then
    trollDate := trollDate + 'nd'
  else if (Day mod 10 = 3) then
    trollDate := trollDate + 'rd'
  else
    trollDate := trollDate + 'th';
  trollDate := trollDate + ' day of ' + MonthStr[Month];
end;

end.
