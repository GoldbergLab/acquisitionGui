function acqgui_overnightBatch(expers)

try
    for nExper = 1:length(expers)    
        rootndx = strfind(expers{nExper}.dir,expers{nExper}.birdname);
        rootdir = expers{nExper}.dir(1:rootndx-2);
        birdName = expers{nExper}.birdname; 
        experName = expers{nExper}.expername;    
        annotationName = [rootdir,filesep, birdName, filesep, birdName,'_annotation_',experName,'.mat'];

        if(strcmp(birdName,'aa316'))
            cafProg = @caf_aa316_Program_v1;
            newroot = rootdir; newroot(1) = 'p';
            currChan = [];
            annotNames = caf_ProcessExperAudio(annotationName, expers(nExper), [], 'triggerAbs', -7, 'thresholdAbs', -11, 'maxFilesPerAnnotation', 300);
            for(nAnnot = 1:length(annotNames))
                if(isempty(cafProg))
                    caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', [], ['getinfo_',birdName], 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);
                else
                    caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', cafProg, ['getinfo_',birdName], 'bOnlyLabled', false, 'whichAnalyses', [1,2,3,5]);
                end                    
            end
            movefile([rootdir,filesep,birdName,filesep,experName],[newroot,filesep,birdName,filesep,experName]);
            copyfile([rootdir,filesep,birdName,filesep,birdName,'*',experName,'*','.mat'], [newroot,filesep,birdName]);            
        end
           
        if(strcmp(birdName,'aa311'))
            cafProg = @caf_aa311_Program_v1;
            newroot = rootdir; newroot(1) = 'p';
            currChan = [];
            annotNames = caf_ProcessExperAudio(annotationName, expers(nExper), [], 'triggerAbs', -8, 'thresholdAbs', -13, 'maxFilesPerAnnotation', 300);
            for(nAnnot = 1:length(annotNames))
                if(isempty(cafProg))
                    caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', [], ['getinfo_',birdName], 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);
                else
                    caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', cafProg, ['getinfo_',birdName], 'bOnlyLabled', false, 'whichAnalyses', [1,2,3,5]);
                end
            end
            movefile([rootdir,filesep,birdName,filesep,experName],[newroot,filesep,birdName,filesep,experName]);
            copyfile([rootdir,filesep,birdName,filesep,birdName,'*',experName,'*','.mat'], [newroot,filesep,birdName]);            
        end
        
        if(strcmp(birdName,'aa319'))
            newroot = rootdir; newroot(1) = 'p';
            currChan = [];
            %annotNames = caf_ProcessExperAudio(annotationName, expers(nExper), [], 'triggerAbs', -7, 'thresholdAbs', -12, 'maxFilesPerAnnotation', 300);
            %for(nAnnot = 1:length(annotNames))
            %    caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', [], ['getinfo_',birdName], 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);
            %end
            movefile([rootdir,filesep,birdName,filesep,experName],[newroot,filesep,birdName,filesep,experName]);
            %copyfile([rootdir,filesep,birdName,filesep,birdName,'*',experName,'*','.mat'], [newroot,filesep,birdName]);            
        end
        
    end
catch
    disp(lasterr);
    warning('Overnight batch failed.');
end