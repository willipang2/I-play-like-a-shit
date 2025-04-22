@import "smuck"

ezScore score("c4:e:g c4:e:g g4:b:d g4:b:d a4:c5:e a4:c5:e g4:b:d |f4:a:c f4:a:c e4:g:b e4:g:b d4:f:a d4:f:a c4:e:g");

ezScorePlayer player(score);

William instrument => Gain split => Gain master => dac;

split  => NRev leftRev => dac.left;
split => PitShift rightShift=> NRev rightRev => dac.right;

0.8 => rightShift.shift; 
0.3 => leftRev.mix;
0.3 => rightRev.mix; 

player.setInstrument(0, instrument);

1.5 => player.rate;
true => player.loop;

spork ~ setVariation(2);

setPan(0.5);

spork ~ autoPan(4, 100);

0.1=> master.gain;

player.play();
eon => now;

for (0 => int i; i < instrument.n_voices; i++) {
    instrument.envs[i].set(10::ms, 100::ms, 0.4, 150::ms);
}

fun void setVariation(int style) {
    if (style == 1) { // Progressive House
        instrument.changeOscType("tri");
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(10::ms, 150::ms, 0.4, 300::ms);
        }
        1.2 => player.rate;
        0.15 => leftRev.mix;
        0.18 => rightRev.mix;
        
        eon => now;
        
    }
    else if (style == 2) { // Dubstep
        instrument.changeOscType("tri");
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(5::ms, 80::ms, 0.3, 100::ms);
        }
        1.0 => player.rate; 
        0.05 => leftRev.mix;
        0.08 => rightRev.mix;
        
        eon => now;
    }
    else if (style == 3) { // Trance
        instrument.changeOscType("sin");
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(20::ms, 100::ms, 0.6, 400::ms);
        }
        1.4 => player.rate; 
        0.2 => leftRev.mix;
        0.25 => rightRev.mix;
        
        eon => now;
    }
}

// Pan position function (0.0 = full left, 1.0 = full right)
fun void setPan(float position) {
    Math.max(0.0, Math.min(1.0, position)) => float panPos;
    Math.cos(panPos * Math.PI/2) => dac.left.gain;
    Math.sin(panPos * Math.PI/2) => dac.right.gain;
}

fun void panLeftToRight(float duration, float steps) {
    duration::second / steps => dur stepTime;
    
    for (0.0 => float i; i <= 1.0; i + 1.0/steps => i) {
        setPan(i);
        stepTime => now;
    }
}

fun void panRightToLeft(float duration, float steps) {
    duration::second / steps => dur stepTime;
    
    for (1.0 => float i; i >= 0.0; i - 1.0/steps => i) {
        setPan(i);
        stepTime => now;
    }
}

fun void autoPan(float cycleTime, float steps) {
    while (true) {
        panLeftToRight(cycleTime/2, steps/2);
        panRightToLeft(cycleTime/2, steps/2);
    }
}
