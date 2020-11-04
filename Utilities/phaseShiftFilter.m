function b_shift = phaseShiftFilter(b)
%Given a signal x and a FIR filter b, let x_sin = filter(b,x) and x_cos =
%filter(b_shift, x).  The envelope of the filter response is equal to
%x_sin.^2 + x_cos.^2.  This is like a real time version of the
%abs(hilbert(x)).

f = b;
F = fft(f);
p = ceil(length(f)/2);
F(2:p) = abs(F(2:p)).*exp(i*(angle(F(2:p)) + pi/2));
F(p+1:end) = abs(F(p+1:end)).*exp(i*(angle(F(p+1:end)) - pi/2));
f = ifft(F);
b_shift = f;