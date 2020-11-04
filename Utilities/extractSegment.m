function sig = extractSegment(sig, ndxRange)
ndxRange(1) = max(1,ndxRange(1));
ndxRange(2) = min(length(sig),ndxRange(2));
sig = sig(ndxRange(1):ndxRange(2));