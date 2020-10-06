function InfoBag = SetPlaneSimConfiguration()
    % set the parameters for raw image generation.
    % Set the working distance.
    WorkDistance                = 1000;
    FocusedVdValue              = 4;            % working distance    
    InfoBag.ObjImgSize          = [6000,4000];  
    
    % Set the simulation parameter.
    InfoBag.FlagRemoveEdge      = false;               % whether remove the micro-lenses which is not complete .
    InfoBag.ParallelFlag        = false;               % whether use parallel computation.
    
    % Set the intrinsic parameters.
    InfoBag.pixelY              = 2000;
    InfoBag.pixelX              = 3000; 
    InfoBag.sxy                 = 0.0055;            % size of  the pixel on sensor
    InfoBag.F                   = 100;                % focal length(mm).
    InfoBag.B                   = 2;                 % Distance between MLA and sensor.
    InfoBag.fm1                 = 2;                 % focal length of micro-lens type 1
    InfoBag.fm2                 = 2;                 % focal length of micro-lens type 2
    InfoBag.fm3                 = 2;                 % focal length of micro-lens type 3
    InfoBag.Dmi                 = 32;                % the diameter of micro-image(pixel)
    InfoBag.k1                  = 0;
    InfoBag.k2                  = 0;
    InfoBag.bL0                 = InfoBag.F * WorkDistance / ( WorkDistance-InfoBag.F )-FocusedVdValue*InfoBag.B; % Distance between MLA and main lens.
    InfoBag.DL                  = 0.9*InfoBag.bL0/( InfoBag.B/(InfoBag.Dmi*InfoBag.sxy) );                        % the diameter of main lens aperture.
    
    % Calculate the rest of parameters
    InfoBag.Dml                 = InfoBag.Dmi*InfoBag.bL0/(InfoBag.bL0+InfoBag.B);  % The diameter of the micro-lenses.
    Lm                          = -InfoBag.bL0;
    Lc                          = -InfoBag.bL0-InfoBag.B;
    InfoBag.K1                  = -(Lm+InfoBag.F)*Lc/( (Lm-Lc)*InfoBag.F  );
    InfoBag.K2                  = Lm*Lc/(Lm-Lc);
    InfoBag.fx                  = (InfoBag.bL0+InfoBag.B)/InfoBag.sxy;
    InfoBag.fy                  = (InfoBag.bL0+InfoBag.B)/InfoBag.sxy;
    InfoBag.cx                  = InfoBag.pixelX/2;
    InfoBag.cy                  = InfoBag.pixelY/2;
   
end