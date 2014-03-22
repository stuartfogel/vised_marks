% pop_runhtb() - Run history template on multiple data files.
% See runhtb for more details.
%
% Usage:
%   >>  com = pop_runhtb(execmeth,HistFName,HistFPath,BatchFName,BatchFPat);
%
% Inputs:
%   execmeth     - Execution method. "serial" = run batch serial mode using
%                  for loop, "parallel" = run batch in parallel mode using
%                  parfor loop (requires Matlab PCT).
%   HistFName    - Name of history template file.
%   HistFPath    - Path of history template file.
%   BatchFName   - Name of batch files.
%   BatchFPath   - Path of batch files
%    
% Outputs:
%   com             - Current command.
%
% See also:
%   savehtb 
%

% Copyright (C) <2006>  <James Desjardins>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_runhtb.m edit history...
%

function VISED_CONFIG = pop_edit_vised_config(fname)

com = ''; % this initialization ensure that the function will return something
% if the user press the cancel button

global VISED_CONFIG
if isempty(VISED_CONFIG);
    VISED_CONFIG=visedconfig_obj;
    %PropGridStr='';
    %ubco=0;
    %ubcv='off';
end
%ubco=1;
%ubcv='on';
PropGridStr=['global vcp;' ...
    'properties=visedconfig2propgrid();' ...
    'properties = properties.GetHierarchy();' ...
    'vcp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.05 .1 .91 .8]);' ...
    ];
%end

% pop up window
% -------------
%if nargin < 4
    
    results=inputgui( ...
        'geom', ...
        {...
        {6 24 [0 0] [1 1]} ... %1 this is just to control the size of the GUI
        {6 24 [0.05 0] [2 1]} ... %2
        ... {6 20 [4.8 0] [1.13 1]} ... %3
        {6 24 [4 0] [1 1]} ... %4
        {6 24 [5 0] [1 1]} ... %5
        ... {6 20 [0.05 18] [1 1]} ... %6
        ... {6 20 [.9 18] [5 1]} ... %6
        ... {6 20 [0.05 19] [1 1]} ... %2.5
        ... {6 20 [.9 19] [5 1]} ... %6
        }, ...
        'uilist', ...
        {...
        {'Style', 'text', 'tag','txt_vcfp','string',blanks(16)} ... %1 this is just to control the size of the GUI
        {'Style', 'pushbutton', 'string', 'Load vised config', ...
        'callback', ...
        ['[configFName, configFPath] = uigetfile(''*.cfg'',''Select vised configuration file:'',''*.cfg'',''multiselect'',''off'');', ...
        'if isnumeric(configFName);return;end;', ...
        'evalin(''base'',[''global VISED_CONFIG;load(fullfile(configFPath,configFName),''''-mat'''');'']);', ...
        PropGridStr]} ... %2
        ... {'Style', 'pushbutton', 'string', 'get dir to clipboard', ...
        ... 'callback', ...
        ... 'dirname=uigetdir;clipboard(''copy'',dirname);'} ... %25
        {'Style', 'pushbutton','string','Save as', ...
        'callback',['[cfgfname,cfgfpath]=uiputfile(''*.*'',''Vised configuration file'');', ...
        'global vcp;global VISED_CONFIG;VISED_CONFIG=propgrid2visedconfig(vcp);', ...
        'save(fullfile(cfgfpath,cfgfname),''VISED_CONFIG'');']}, ...
        {'Style', 'pushbutton','string','Clear','callback',['VISED_CONFIG=visedconfig_obj;',PropGridStr]}, ...
        ... {'Style', 'pushbutton','string','System', ...
        ... 'callback',['evalstr=strcat(''system('''''',get(findobj(gcbf,''tag'',''edt_syscmd''),''string''),'''''');'');',...
        ... 'disp(evalstr);', ...
        ... 'eval(evalstr{:});']}, ...
        ... {'Style', 'edit', 'tag','edt_syscmd'}, ... %9
        ... {'Style', 'pushbutton', 'string', 'Refresh', ...
        ... 'callback', ...
        ... 'close(gcf);CONTEXT_CONFIG=pop_context_edit;'} ... %2
        ... {'Style', 'popup', 'string', CONTEXT_CONFIG.system_cmds, 'value',1,'tag', 'pop_syscmd', ...
        ... 'callback',['tmpcmds=get(findobj(gcbf,''tag'',''edt_syscmd''),''string'');', ...
        ... 'tmpval=get(findobj(gcbf,''tag'',''pop_syscmd''),''value'');', ...
        ... 'set(findobj(gcbf,''tag'',''edt_syscmd''),''string'', context_strswap(eval(''CONTEXT_CONFIG.system_cmds(tmpval)'')));']} ...
        }, ...
        'title', 'Vised configuration -- pop_edit_vised_config()',...%, ...
        'eval',PropGridStr ...
        );

    if isempty(results);return;end

    global vcp;
    global VISED_CONFIG;
    VISED_CONFIG=propgrid2visedconfig(vcp);
  
%end;
