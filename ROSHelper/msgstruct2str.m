function msgStructOut = msgstruct2str(S,msgname,pkg)
    arguments
        S
        msgname
        pkg
    end

    % Prep msg carrier
    msgStructOut = struct(msgname,string.empty());

    % Generate messages
    names = fieldnames(S);
    for i = 1:numel(names)
        if isstruct(S.(names{i}))
            msgStructOut.(msgname) = [msgStructOut.(msgname); pkg + "/" + names{i} + " " + lower(names{i})];
            msgStructOut.(names{i}) = msgstruct2str(S.(names{i}),names{i},pkg);
        else
            strArr = S.(names{i});
            for s = 1:numel(strArr)
                str = split(strArr(s)," ");
                str(1) = strrep(str(1),"<pkgname>",pkg);
                msgStructOut.(msgname) = [msgStructOut.(msgname);str(1) + " " + lower(str(2))];
            end
        end
    end
end