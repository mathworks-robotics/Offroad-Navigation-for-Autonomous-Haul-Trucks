function [msgStr,msgName] = ros2msgfromstruct(S,nv)
    arguments
        S (:,1) {mustBeA(S,"coder.StructType")};
        nv.Type (1,1) string {mustBeMember(nv.Type,["msg","srv"])} = "msg";
        nv.Folder (1,1) string {mustBeFolder} = pwd;
        nv.PkgName (1,1) string = "custom_msgs";
        nv.Name (1,1) string = "DefaultMsg";
    end
    switch nv.Type
        case "msg"
            nExpStruct = 1;
        case "srv"
            nExpStruct = 2;
    end
    validateattributes(S,{'coder.StructType'},{'numel',nExpStruct},'struct2msgdef',"S");

    % Generate msg struct
    [msgStruct,hasFixedMultiDim] = struct2cstr(S(1));

    % Convert to string
    pkgName = nv.PkgName;
    pkgDir = fullfile(nv.Folder,pkgName);
    msgStr = msgstruct2str(msgStruct,nv.Name,pkgName);

    if nExpStruct == 2
        % Convert response to string
        msgStr.(nv.Name) = [msgStr.(nv.Name); ];
        [msgStruct,hasFixed2] = struct2cstr(S(2));
        hasFixedMultiDim = hasFixedMultiDim || hasFixed2;
        str = msgstruct2str(msgStruct,nv.Name,pkgName);
        
        % Append response to initial message
        names = fieldnames(str);
        msgStr.(nv.Name) = [msgStr.(nv.Name);'---';str.(names{1})];

        % Add any nested structs to list of types that must be generated
        for i = 2:numel(names)
            msgStr.(names{i}) = str.(names{i});
        end
    end

    if hasFixedMultiDim
        msgStr.FixedDims = struct("FixedDims",["uint32[] dims";"uint32 n"]);
    end

    % Generate nested messages
    names = fieldnames(msgStr);
    writeToFile(msgStr,names{1},pkgDir,nv.Type);
end

function writeToFile(msgStr,name,location,type)
    names = fieldnames(msgStr);
    for i = 1:numel(names)
        field = msgStr.(names{i});
        switch string(class(field))
            case "struct"
                writeToFile(field,names{i},location,"msg");
            case "string"
                fdir = fullfile(location,type);
                if ~exist(fdir,"dir")
                    mkdir(fdir);
                end
                fname = fullfile(location,type,name+"."+type);
                fid = fopen(fname,'wt');
                fClean = onCleanup(@()fclose(fid));
                fprintf(fid,'%s\n',msgStr.(name));
        end
    end
end