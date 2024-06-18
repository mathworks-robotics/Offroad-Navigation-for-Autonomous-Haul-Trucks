function geomObj = exampleHelperVehicleGeometry(length,width,outputFormat,nv)
%exampleHelperVehicleGeometry Generates geometry info for vehicleCostmap and controllerTEB
%

% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        length (1,1) double {mustBePositive, mustBeFinite}
        width (1,1) double {mustBePositive, mustBeFinite}
        outputFormat (1,:) char {mustBeMember(outputFormat,{'teb','collisionChecker'})}
        nv.LocalPoseOffset (1,1) double {} = nan
        nv.Wheelbase (1,1) double {mustBeFinite, mustBePositive} = length
    end
    switch string(outputFormat)
        case "teb"
            geomObj = struct("Dimension",[length width],"Shape","Rectangle");
        case "collisionChecker"
            if isnan(nv.LocalPoseOffset)
                rearOverhang = (length-nv.Wheelbase)/2;
            else
                rearOverhang = length/2-nv.LocalPoseOffset;
            end
            L = coder.const(length);
            W = coder.const(width);
            geomObj = vehicleDimensions(L,W);
            geomObj.RearOverhang = rearOverhang;
            geomObj.Wheelbase = nv.Wheelbase;
    end
end