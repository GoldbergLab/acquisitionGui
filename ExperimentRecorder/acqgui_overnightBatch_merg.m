function acqgui_overnightBatch(expers)

try
    for nExper = 1:length(expers)    
        rootndx = strfind(expers{nExper}.dir,expers{nExper}.birdname);
        rootdir = expers{nExper}.dir(1:rootndx-2);
        birdName = expers{nExper}.birdname; 
        experName = expers{nExper}.expername;    
        annotationName = [rootdir,filesep, birdName, filesep, birdName,'_annotation_',experName,'.mat'];

<<<<<<< .mine
        if(strcmp(birdName,'aa291'))
            newroot = rootdir; newroot(1) = 'n'; 
=======
        if(strcmp(birdName,'aa286'))
            newroot = rootdir; newroot(1) = 'n'; 
>>>>>>> .r239
            copyfile([rootdir,filesep,birdName,filesep,experName],[newroot,filesep,birdName,filesep,experName]);            
<<<<<<< .mine
            currChan = expers{nExper}.sigCh(1);
            annotNames = caf_ProcessExperAudio(annotationName, expers(nExper), [], 'triggerAbs', -10, 'thresholdAbs', -13, 'maxFilesPerAnnotation', 300);
            for(nAnnot = 1:length(annotNames))
                caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', [], 'getinfo_aa291', 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);
            end
=======
            currChan = [];
            annotNames = caf_ProcessExperAudio(annotationName, expers(nExper), [], 'triggerAbs', -6, 'thresholdAbs', -10.5, 'maxFilesPerAnnotation', 300);
            for(nAnnot = 1:length(annotNames))
                caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', [], ['getinfo_',birdName], 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);                       
            end
>>>>>>> .r239
        end
<<<<<<< .mine
        if(strcmp(birdName,'aa275'))
            newroot = rootdir; newroot(1) = 'n'; 
            copyfile([rootdir,filesep,birdName,filesep,experName],[newroot,filesep,birdName,filesep,experName]);            
            currChan = expers{nExper}.sigCh(1);
            annotNames = caf_ProcessExperAudio(annotationName, expers(nExper), [], 'triggerAbs', -8, 'thresholdAbs', -12, 'maxFilesPerAnnotation', 300);
            for(nAnnot = 1:length(annotNames))
                caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', [], 'getinfo_aa275', 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);                       
            end
        end
        if(strcmp(birdName,'aa287'))
            newroot = rootdir; newroot(1) = 'n';
            copyfile([rootdir,filesep,birdName,filesep,experName],[newroot,filesep,birdName,filesep,experName]);
            currChan = [];
            annotNames = caf_ProcessExperAudio(annotationName, expers(nExper), [], 'triggerAbs', -5, 'thresholdAbs', -10.5, 'maxFilesPerAnnotation', 300);
            for(nAnnot = 1:length(annotNames))
                caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', [], ['getinfo_',birdName], 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);
            end
        end
=======
        
        if(strcmp(birdName,'aa287'))
            newroot = rootdir; newroot(1) = 'n'; 
            copyfile([rootdir,filesep,birdName,filesep,experName],[newroot,filesep,birdName,filesep,experName]);            
            currChan = [];
            annotNames = caf_ProcessExperAudio(annotationName, expers(nExper), [], 'triggerAbs', -5, 'thresholdAbs', -10.5, 'maxFilesPerAnnotation', 300);
            for(nAnnot = 1:length(annotNames))
                caf_ProcessAnnotation(annotNames{nAnnot}, currChan, 'all', [], ['getinfo_',birdName], 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);                       
            end
        end
>>>>>>> .r239
    end
catch
    disp(lasterr);
    warning('Overnight batch failed.');
end