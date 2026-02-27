function [hdr] = fitsHDUhdrcell2struct(hdrcell)
% [hdr] = fitsHDUhdrcell2struct(hdrcell)
%   Interpret the header of fits HDU in the cell format into a struct format.
%   The header struct hdr stores only keywords with values. COMMENT and HISTORY
%   keywords are ignored. CONTINUE keywords are properly concatenated. Then each
%   keyword is stored to a field named by its keyword name.
% 
%   Values are converted to MATLAB style formats:
%     
%     + Wrapping single quotes (') are stripped.
%     + Empty strings ("'  '") are filled with FITS_KEYWORD_EMPTY_STRING.
%     + Null strings are filled with FITS_KEYWORD_NULL_STRING.
%     + "T" and "F" are replaced with true and false.
%     + Any other values that are not wrapped with single quotes will be
%       converted to double if they can otherwise left as a string.
%
% INPUTS
% ------
% hdrcell: (n x 3) cell array
%   Header in a cell format, the first, second, and third columns are keyword
%   name, value, and comment. This is assumed to be the output of
%   fitsHDUhdrread2cell.
%
% OUTPUTS
% -------
% hdr: struct
%   Header of fit HDU as a struct.
%   

import matlab.io.*;

hdr = [];
j=1;
nkey = size(hdrcell, 1);
while j <= nkey
    keyname = hdrcell{j, 1};
    value = hdrcell{j, 2};
    if ~any(keyname == ["", "COMMENT", "HISTORY"])
        if ~isempty(value)
            if value ~= "" && value{1}(1) == "'" && value{1}(end) == "'"
                if ~isempty(regexp(value, "^'\s+'$", "ONCE"))
                    value = "";
                elseif value == "''"
                    value = [];
                else
                    % value = string(strip(value, "both", "'"));
                    value{1} = value{1}(2:end-1);
                    while value{1}(end) == "&" && j < nkey ...
                            && hdrcell{j+1, 1} == "CONTINUE"
                        j = j + 1;
                        value_cont = hdrcell{j, 2};
                        if value_cont{1}(1) == "'" && value_cont{1}(end) == "'"
                            % value_cont = strip(value_cont, "both", "'");
                            value_cont{1} = value_cont{1}(2:end-1);
                        end
                        % value = strip(value, "right", "&") + value_cont;
                        value = string(value{1}(1:end-1)) + value_cont;
                    end
                    value = strip(value, "both", " ");
                end
            elseif value == "T"
                value = true;
            elseif value == "F"
                value = false;
            else
                value_dbl = str2double(value);
                if ~isnan(value_dbl), value = value_dbl; end
            end
            hdr.(keyname) = value;
        end
    end

    j = j + 1;
    
end

end

