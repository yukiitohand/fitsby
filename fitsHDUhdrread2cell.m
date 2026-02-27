function [hdrcell, hdr_cards] = fitsHDUhdrread2cell(fptr)
% [hdrcell, hdr_cards] = fitsHDUhdrread2cell(fptr)
%   Read the header of Fits HDU. hdrcell is a n x 3 cell array, where n is the
%   number of cards (output of fits.getHdrSpace).
%
%   The first, second, and third columns of hdrcell are keyword name, value, and
%   comment, respectively. If value is undefined (when value indicator "= " is
%   present but values are not given), it is filled with FITS_KEYWORD_UNDEFINED.
%   
%   If the value is wrapped with single quotes ('), they are retained, which
%   tell whether it is interpreted as text.
%
%   hdrcards is a string array of raw header cards with white trailing spaces
%   stripped. This is returned mostly for debugging purpose. Note that a header
%   card means a single line of raw text of the header. 
%
% INPUTS
% ------
% fptr: file pointer, output of fits.openFile
%   this pointer must be moved to the HDU you want to read by fits.
%
% OUTPUTS
% -------
% hdrcell: cell
%   Header in a cell format, the first, second, and third columns are keyword
%   name, value, and comment.
% 
% hdrcards: string array
%   Raw header cards with white trailing spaces stripped. The shape is (n x 1)
%   where n is the number of cards except for END. 
%   

import matlab.io.*;
% Read Hdr
n = fits.getHdrSpace(fptr);
hdr_cards = strings(n, 1);
hdrcell = cell(n, 3);
% for j = 1:n
%     card = fits.readRecord(fptr, j);
%     hdr_cards{j, 1} = card;
% end
% row_lens = strlength(hdr_cards);
% rows_lenge8 = row_lens >= 8;
% keynames = strip(hdr_cards(rows_lenge8).extractBefore(9), "right", " ");
% rows_lenge8_idx = find(rows_lenge8);
% keyempty = keynames ~= "";
% hdrcell(rows_lenge8_idx(keyempty), 1) = num2cell(keynames(keyempty));
% rows_comment = ismember(keynames, ["", "COMMENT", "HISTORY"]);
% comment = strip(hdr_cards(rows_lenge8_idx(rows_comment)).extractAfter(8), "right");
% hdrcell(rows_lenge8_idx(rows_comment), 3) = num2cell(comment);
% keynocomment = ~rows_comment;
% vc_ind_after = 10 * ones(sum(keynocomment), 1);
% vc_ind_after(keynames(keynocomment) == "CONTINUE") = 8;
% ptrn = "\s*(?<value>('.*'|[^/]*))\s*/{0,1}\s*(?<comment>.*){0,1}\s*";
% m = regexpi( ...
%     hdr_cards(rows_lenge8_idx(keynocomment), 1).extractAfter(vc_ind_after), ...
%     ptrn, "names");
% m = [m{:}];
% values = strip([m.value], "both", " ");
% comments = strip([m.comment], "both", " ");
% hdrcell(rows_lenge8_idx(keynocomment), 2) = num2cell(values);
% hdrcell(rows_lenge8_idx(keynocomment), 3) = num2cell(comments);

for j = 1:n
    hdr_cards{j, 1} = fits.readRecord(fptr, j);
    if hdr_cards(j, 1) ~= ""
        % Keyword name is bytes 1-8 (8 bytes).
        keyname = strip(hdr_cards(j, 1).extractBefore( ...
            min(8, strlength(hdr_cards(j, 1))) + 1), "right", " ");
        if any(keyname == ["", "COMMENT", "HISTORY"])
            % if keyname == "", keyname = []; end
            value = [];
            % comment = strip(string(card(9:end)), "right");
            comment = strip(hdr_cards(j,1).extractAfter(8), "both", " ");
        else
            ptrn = "\s*(?<value>('.*'|[^/]*?[^/\s]*))\s*+[/]{0,1}+" + ...
                "\s*(?<comment>.*)?\s*";
            if keyname == "CONTINUE"
                vcindaft = 8;
            else
                vcindaft = 10;
            end
            % m = regexpi(card(vc_strt_ind:end), ptrn, "names");
            % value = strip(string(m.value), "both", "_");
            m = regexpi(hdr_cards(j,1).extractAfter(vcindaft), ptrn, "names");
            value = m.value;
            if keyname ~= "CONTINUE" && value == ""
                % if keyname is "CONTINUE", then it might cause a concatenating
                % issue later, so leave empty string.
                % value = FITS_KEYWORD_UNDEFINED;
                value = [];
            end
            comment = m.comment;
        end
    else
        keyname = "";
        comment = [];
        value = [];
    end
    hdrcell{j, 1} = keyname;
    hdrcell{j, 2} = value;
    hdrcell{j, 3} = comment;
end

end

