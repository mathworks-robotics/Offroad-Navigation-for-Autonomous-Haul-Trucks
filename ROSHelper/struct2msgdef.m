function msgStruct = struct2msgdef(S,nv)
    arguments
        S (:,1) {mustBeA(S,"coder.StructType")};
        nv.Type (1,1) string {mustBeMember(nv.Type,["msg","srv"])} = "msg";
    end
    switch nv.Type
        case "msg"
            nExpStruct = 1;
        case "srv"
            nExpStruct = 2;
    end
    validateattributes(S,{'coder.StructType'},{'numel',nExpStruct},'struct2msgdef',"S");
    msgStruct = struct2cstr(S(1));

    if nExpStruct == 2
        msgStruct(end+1,1) = struct2cstr(S(2));
    end
end