function scheduler = getScheduler(name)

    if strcmpi(name, 'lsf')
        scheduler = plato.scheduler.Lsf();
    else
        throw(MException([mfilename ':getScheduler'],...
              ['Unknown scheduler: ' name]))
    end

end
