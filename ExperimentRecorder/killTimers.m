function killTimers()
% Kill any and all timers
listOfTimers = timerfindall;
if ~isempty(listOfTimers)
    delete(listOfTimers(:));
end