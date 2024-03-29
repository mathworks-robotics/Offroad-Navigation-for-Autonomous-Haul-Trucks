function [dataTypeStr,hasFixedMultiDim] = convertFieldToC(sField,name,vszTF)
    arguments
        sField (1,1) {mustBeA(sField,'coder.PrimitiveType')}
        name (1,1) string
        vszTF {mustBeMember(vszTF,[0,1])} = []
    end
    hasFixedMultiDim = 0;
    if isempty(vszTF)
        vszTF = isVarsize(sField);
    end
    cType = getCType(sField);
    if vszTF && cType == "bool"
        warning("Multi-dim logical not supported, converting to int8");
        cType = "int8";
    end
    typeChar = char(cType);
    isMatrix = numel(sField.SizeVector) > 2 || (nnz(sField.SizeVector > 1) > 1);
    if vszTF
        dataTypeStr = "std_msgs/" + upper(typeChar(1)) + typeChar(2:end) + "MultiArray " + ...
            name;
    else
        if isMatrix
            dataTypeStr = cType + "[" + prod(sField.SizeVector) + "] " + name;
            dataTypeStr(end+1,1) = "<pkgname>/FixedDims " + name + "_dims";
            hasFixedMultiDim = 1;
        else
            if prod(sField.SizeVector) > 1
                szStr = "[" + num2str(prod(sField.SizeVector)) + "]";
            else
                szStr = "";
            end
            dataTypeStr = cType + szStr + " " + name;
        end
    end
end

function cType = getCType(sField)
    mType = sField.ClassName;
    switch string(mType)
        case "double"
            cType = "float64";
        case "single"
            cType = "float32";
        case "logical"
            cType = "bool";
        case {"char","int8","uint8","int16","uint16","int32","uint32","int64","uint64"}
            cType = mType;
        otherwise
            error("Non-basic type");
    end
end

function vszTF = isVarsize(sField)
    vszTF = any(sField.VariableDims);
end