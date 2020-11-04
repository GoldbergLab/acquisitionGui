TG_estimatePitch

fft1 with gaussian window
fft2 with deriv of gaussian window

f = dPhase/dt
t = t - dPhase/df

dPhase/dt = ff1/fft2 or something like that
dPhase/df = ???

Move power in fft according to these phase adjusted values.

(dPhase/df is like estimating how far away something happened based on sound.)

Estimate pitch using harmonic method...
   
