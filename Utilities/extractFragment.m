function clipSig = extractFragment(sig, sigFragment)
ndxStart = ceil((length(sig)-1) * sigFragment(1)) + 1;
ndxEnd = floor((length(sig)-1) * sigFragment(2)) + 1;
clipSig = sig(ndxStart:ndxEnd);