@import "smuck"


ezScore score("c4:e:g c4:e:g g4:b:d g4:b:d a4:c5:e a4:c5:e g4:b:d |f4:a:c f4:a:c e4:g:b e4:g:b d4:f:a d4:f:a c4:e:g");

ezScorePlayer player(score);
William instrument => dac;

player.setInstrument(0, instrument);
1 => player.rate;
false => player.loop;

player.play();
eon => now;