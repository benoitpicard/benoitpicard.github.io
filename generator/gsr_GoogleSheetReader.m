function result = gsr_GoogleSheetReader(DOCID)
% result = GetGoogleSpreadsheet(DOCID)
% Download a google spreadsheet as csv and import into a Matlab cell array.
%
% [DOCID] see the value after 'key=' in your spreadsheet's url
%           e.g. '0AmQ013fj5234gSXFAWLK1REgwRW02hsd3c'
%
% [result] cell array of the the values in the spreadsheet
%
% IMPORTANT: The spreadsheet must be shared with the "anyone with the link" option
%
% This has no error handling and has not been extensively tested.
% Please report issues on Matlab FX.
%
% DM, Jan 2013
%


% Build CSV export URL
csvURL = ['https://docs.google.com/spreadsheets/d/',DOCID,'/export?format=csv&id=',DOCID];

% Try to read via high-level functions (webread/urlread). If not available, fall back to curl via system command.
resultChar = '';
try
   % Try webread (MATLAB)
   resultChar = webread(csvURL);
catch
   try
      % Try Octave/MATLAB urlread
      resultChar = urlread(csvURL);
   catch
      try
         % Fall back to curl (must be available in PATH)
         [status, out] = system(['curl -L -s "', csvURL, '"']);
         if status == 0
            resultChar = out;
         else
            error('curl failed');
         end
      catch
         error('Could not download CSV: try curl in PATH or use a MATLAB/Octave build with webread/urlread support');
      end
   end
end

% Convert CSV text to cell array
result = parseCsv(resultChar);

end

function data = parseCsv(data)
% splits data into individual lines
% Normalize line endings and split into lines
data = strrep(data, '\r\n', '\n');
data = strrep(data, '\r', '\n');
lines = regexp(data, '\n', 'split');

% Parse each line using textscan with %q for quoted fields
numLines = numel(lines);
rows = cell(numLines, 1);
maxCols = 0;
for ii = 1:numLines
   line = lines{ii};
   if isempty(line)
      tokens = {''};
   else
      try
         % First try textscan (handles quoted fields well in MATLAB/Octave)
         tmp = textscan(line, '%q', 'delimiter', ',');
         tokens = tmp{1}(:)'; % row vector of tokens
      catch
         % Fall back to regexp-based CSV split that handles quoted fields
            tokens = regexp(line, '"([^\"]|\"\")*"|[^,]*', 'match');
      end
      % Unquote any quoted fields, and unescape double quotes
      for k = 1:numel(tokens)
         t = tokens{k};
         if numel(t) >= 2 && t(1) == '"' && t(end) == '"'
            t = t(2:end-1);
            t = strrep(t, '""', '"');
         end
         tokens{k} = t;
      end
   end
   rows{ii} = tokens;
   maxCols = max(maxCols, numel(tokens));
end

% Assemble into a full cell matrix padded with empty strings where needed
data = repmat({''}, numLines, maxCols);
for ii = 1:numLines
   t = rows{ii};
   for jj = 1:numel(t)
      data{ii, jj} = t{jj};
   end
end

end

% readstream is no longer used in this Octave-compatible version.
