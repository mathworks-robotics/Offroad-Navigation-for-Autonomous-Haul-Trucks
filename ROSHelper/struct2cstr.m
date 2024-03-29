function [msgStruct,hasFixedMultiDim] = struct2cstr(sType)
    arguments
        sType (1,1) {mustBeA(sType,'coder.StructType')};
    end
    fields = sType.Fields;
    names = fieldnames(fields);
    msgStruct = struct();
    hasFixedMultiDim = 0;
    for i = 1:numel(names)
        sField = fields.(names{i});
        if isa(sField,'coder.StructType')
            [str,hasFixed] = struct2cstr(sField);
        else
            [str,hasFixed] = convertFieldToC(sField,names{i});
        end
        msgStruct.(names{i}) = str;
        hasFixedMultiDim = hasFixedMultiDim | hasFixed;
    end
end