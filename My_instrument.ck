// My_instrument.ck -
@import "smuck"

public class William extends ezInstrument {
    20 => int n_voices;
    UGen @ oscs[n_voices];
    ADSR envs[n_voices];
    int active[n_voices];
    string oscTypes[n_voices]; 
    
    Gain g => LPF filter => ADSR masterEnv => NRev reverb => outlet;
    
    SinOsc lfo => blackhole;
    
    float modDepth;
    float modRate;
    float filterCutoff;
    float filterQ;
    float reverbMix;
    
    {
        setVoices(n_voices);
        for (0 => int i; i < n_voices; i++) {
            SinOsc sin @=> oscs[i];
            "sin" => oscTypes[i];
            oscs[i] => envs[i] => g;
            envs[i].set(80::ms, 100::ms, 0.7, 200::ms);
            0 => active[i];
        }
        0.3 => g.gain;
        2000.0 => filter.freq;
        1.0 => filter.Q;
        0.1 => reverb.mix;
        
        masterEnv.set(10::ms, 0::ms, 1.0, 10::ms);
        masterEnv.keyOn();
        0.1 => modDepth;
        0.5 => modRate;
        modRate => lfo.freq;
        2000.0 => filterCutoff;
        1.0 => filterQ;
        0.1 => reverbMix;
        
        spork ~ runModulation();
    }
    
    fun void changeOscType(string type) {
        for (0 => int i; i < n_voices; i++) {
            440.0 => float freq;
            
            if (oscs[i] != null) {
                if (oscTypes[i] == "sin") {
                    (oscs[i] $ SinOsc).freq() => freq;
                } else if (oscTypes[i] == "tri") {
                    (oscs[i] $ TriOsc).freq() => freq;
                } else if (oscTypes[i] == "sqr") {
                    (oscs[i] $ SqrOsc).freq() => freq;
                } else if (oscTypes[i] == "saw") {
                    (oscs[i] $ SawOsc).freq() => freq;
                } else if (oscTypes[i] == "pulse") {
                    (oscs[i] $ PulseOsc).freq() => freq;
                }
                
                oscs[i] =< envs[i];
            }
            
            // Create new oscillator based on type
            if (type == "sin") {
                new SinOsc @=> oscs[i];
                "sin" => oscTypes[i];
                freq => (oscs[i] $ SinOsc).freq;
            } else if (type == "tri") {
                new TriOsc @=> oscs[i];
                "tri" => oscTypes[i];
                freq => (oscs[i] $ TriOsc).freq;
            } else if (type == "sqr") {
                new SqrOsc @=> oscs[i];
                "sqr" => oscTypes[i];
                freq => (oscs[i] $ SqrOsc).freq;
            } else if (type == "saw") {
                new SawOsc @=> oscs[i];
                "saw" => oscTypes[i];
                freq => (oscs[i] $ SawOsc).freq;
            } else if (type == "pulse") {
                new PulseOsc @=> oscs[i];
                "pulse" => oscTypes[i];
                freq => (oscs[i] $ PulseOsc).freq;
                0.5 => (oscs[i] $ PulseOsc).width;
            }
            
            oscs[i] => envs[i];
        }
    }
    
    // Set pulse width for pulse oscillators
    fun void setPulseWidth(float width) {
        for (0 => int i; i < n_voices; i++) {
            if (oscTypes[i] == "pulse") {
                Math.min(1.0, Math.max(0.0, width)) => (oscs[i] $ PulseOsc).width;
            }
        }
    }
    
    // New filter control methods
    fun void setFilterFreq(float freq) {
        freq => filterCutoff;
        freq => filter.freq;
    }
    
    fun void setFilterQ(float q) {
        q => filterQ;
        q => filter.Q;
    }
    
    // Reverb control
    fun void setReverbMix(float mix) {
        Math.min(1.0, Math.max(0.0, mix)) => reverbMix;
        reverbMix => reverb.mix;
    }
    
    // LFO modulation control
    fun void setModRate(float rate) {
        rate => modRate;
        rate => lfo.freq;
    }
    
    fun void setModDepth(float depth) {
        depth => modDepth;
    }
    
    // Set all envelope parameters at once
    fun void setAllEnvelopes(dur attack, dur decay, float sustain, dur release) {
        for (0 => int i; i < n_voices; i++) {
            envs[i].set(attack, decay, sustain, release);
        }
    }
    
    // Set master gain
    fun void setGain(float gain) {
        gain => g.gain;
    }
    
    // Run LFO modulation continuously
    fun void runModulation() {
        while (true) {
            // Apply LFO to filter frequency
            filterCutoff + (lfo.last() * modDepth * filterCutoff) => filter.freq;
            10::ms => now;
        }
    }
    
    // Improved noteOn
    fun void noteOn(ezNote note, int voice) {
        1 => active[voice];
        
        // Set frequency based on type
        if (oscTypes[voice] == "sin") {
            Std.mtof(note.pitch()) => (oscs[voice] $ SinOsc).freq;
        } else if (oscTypes[voice] == "tri") {
            Std.mtof(note.pitch()) => (oscs[voice] $ TriOsc).freq;
        } else if (oscTypes[voice] == "sqr") {
            Std.mtof(note.pitch()) => (oscs[voice] $ SqrOsc).freq;
        } else if (oscTypes[voice] == "saw") {
            Std.mtof(note.pitch()) => (oscs[voice] $ SawOsc).freq;
        } else if (oscTypes[voice] == "pulse") {
            Std.mtof(note.pitch()) => (oscs[voice] $ PulseOsc).freq;
        }
        
        note.velocity() => float vel;
        (1.0 - vel) * 100::ms + 10::ms => dur attackTime;
        vel * 150::ms + 50::ms => dur decayTime;
        vel * 0.3 + 0.5 => float sustainLevel;
        
        envs[voice].set(attackTime, decayTime, sustainLevel, 200::ms);
        envs[voice].keyOn();
    }
    
    fun void noteOff(ezNote note, int voice) {
        if (active[voice]) {
            envs[voice].keyOff();
            0 => active[voice];
        }
    }
    
    fun void muteAll() {
        for (0 => int i; i < n_voices; i++) {
            if (active[i]) {
                envs[i].keyOff();
                0 => active[i];
            }
        }
    }
    
    fun void fadeOut(dur fadeTime) {
        masterEnv.set(10::ms, 0::ms, 1.0, fadeTime);
        masterEnv.keyOff();
    }
    
    fun void fadeIn(dur fadeTime) {
        masterEnv.set(fadeTime, 0::ms, 1.0, 10::ms);
        masterEnv.keyOn();
    }
}

