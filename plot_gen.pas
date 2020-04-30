(* Generate names and plot elements *)

unit plot_gen;

{$mode objfpc}{$H+}{$R+}

interface

var

  playerName: string;

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

(* Generate a name for the player *)
procedure generateName;

implementation

uses
  player;

procedure generateName;
var
  a, b: byte;
begin
  a := Random(73);
  b := Random(62);
  playerName := firstSyllable[a] + secondSyllable[b];
end;

end.
