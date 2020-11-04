function dirsync_oneway(dir_from, dir_to, bSubFolders)

if(~exist('dir_from'))
    dir_from = uigetdir('', 'What would you like to sync files from?');
end

if(~exist('dir_to'))
    dir_to = uigetdir('', 'What would you like to sync files to?');
end

if(~exist('bSubFolders'))
    bSubFolders = true;
end

dfrom = dir(dir_from);
dto = dir(dir_to);
sizeto = length(dto);

tondx = 2;
for(nF = 1:length(dfrom))
    if(strcmp(dfrom(nF).name, '.'))
        continue;
    end
    if(strcmp(dfrom(nF).name, '..'))
        continue;
    end    
    if(dfrom(nF).isdir)   
        if(bSubFolders)
            if(~isdir([dir_to,filesep,dfrom(nF).name]))
                if(~isempty(dir([dir_to,filesep,dfrom(nF).name])))
                    error('Sync incomplete: to_file has the same name as a from_folder');
                end
                status = mkdir([dir_to,filesep,dfrom(nF).name]);
                if(~status)
                    error('Sync incomplete: unable to create a new folder on dir_to.');
                end
            end 
            dirsync_oneway([dir_from,filesep,dfrom(nF).name], [dir_to,filesep,dfrom(nF).name], bSubFolders);
        end
    else    
        if(tondx > sizeto)
            copyfile([dir_from, filesep, dfrom(nF).name] , dir_to);
            fprintf('.');
        else
            while(tondx<=sizeto && issortedcellchar({dto(tondx).name,dfrom(nF).name}))
                tondx = tondx + 1;
            end   
            if(~strcmp(dfrom(nF).name,dto(tondx-1).name))
                copyfile([dir_from, filesep, dfrom(nF).name] , dir_to);
                fprintf('.');
            end
        end
    end
end
    
disp(['directory sync successful: ' dir_from, ' to ', dir_to]);

