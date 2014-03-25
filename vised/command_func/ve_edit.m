function ve_edit(varargin)%GET RID OF EEG...

options = varargin;
for index = 1:length(options)
    if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = { options{index} }; end;
end;
if ~isempty( varargin ), g=struct(options{:});
else g=[]; end;

try g.quick_evtmk;              catch
    try g.quick_evtmk=g.qem;    catch,     g.quick_evtmk		= ''; 	end;end;

try g.quick_evtrm;              catch
    try g.quick_evtrm=g.qer;    catch,     g.quick_evtrm		= 'off';end;end;

try g.quick_chanflag;           catch
    try g.quick_chanflag=g.qcf; catch,     g.quick_chanflag		= ''; 	end;end;

try g.select_mark;              catch
    try g.select_mark=g.sm;     catch,     g.select_mark        ='off'; end;end;

try g.add_winrej_mark;          catch
    try g.add_winrej_mark=g.awm;catch,     g.add_winrej_mark    ='';    end;end;
try g.rm_winrej_mark;           catch
    try g.rm_winrej_mark=g.rwm; catch,     g.rm_winrej_mark     ='';    end;end;
try g.data_move;                catch
    try g.data_move=g.dm;       catch,     g.data_move          ='off';    end;end;

%ax1 = findobj('tag','backeeg','parent',gcf);
%tmppos = get(ax1, 'currentpoint');
g.tmppos=get(findobj('tag','eegaxis','parent',gcf), 'currentpoint');

% Store "UserData" and "temppos" variables to "g" structures.             
udf=get(gcf,'userdata');
uda=get(gca,'userdata');

%g.tmppos=tmppos;

%g.quick_evtmk=tmp_g.quick_evtmk;
%g.quick_evtrm=tmp_g.quick_evtrm;
%g.quick_chanflag=tmp_g.quick_chanflag;

%g.select_mark=tmp_g.select_mark;
%g.add_winrej_mark=tmp_g.add_winrej_mark;
%g.rm_winrej_mark=tmp_g.rm_winrej_mark;

%nevents=length(udf.events);

%datasize=size(uda);

if ~isfield(udf.events, 'index');
    for i=1:length(udf.events);
        udf.events(i).index=i;
        udf.events(i).proc='none';
    end
end

% Define relative starting point for figure window latencies: "EEG.eventedit.WinStartPnt"
if size(uda,3)==1; % define WinStartPt. data point at wich current display window begins.
    g.eventedit.WinStartPnt=udf.time*udf.srate;
    g.eventedit.EpochIndex=1;
else
    g.eventedit.WindowIndex=udf.time+1;
    g.eventedit.WinStartPnt=g.eventedit.WindowIndex*size(uda,2)-(size(uda,2)-1); 
    g.eventedit.EpochIndex=ceil((g.tmppos(1,1)+g.eventedit.WinStartPnt)/size(uda,2));
end;

g.eventedit.PosLat=round(g.tmppos(1,1)+g.eventedit.WinStartPnt);


% Identify selected channel.
% By default use the 'Eelec' tex display of eegplot.
tmpChanIndex=strmatch(get(findobj(gcf,'Tag','Eelec'),'string'),{udf.eloc_file.labels},'exact');
if length(tmpChanIndex)==1;
    g.eventedit.ChanIndex=tmpChanIndex;
else
    % Otherwise calculate ChanIndex from tmppos.
    nWin=(udf.chans-udf.dispchans)+1;
    stepWin=1/nWin;
    if udf.dispchans==udf.chans;
        curWinStrt=0;
    else
        curWinStrt=floor((1-get(findobj('tag','eegslider'),'value'))/stepWin);
    end
    curWinEnd=curWinStrt+udf.dispchans;

    YIndex=floor((tmppos(1,2)/(1/(udf.dispchans+1)))-.5);
    g.eventedit.ChanIndex=(curWinEnd-YIndex);

    if g.eventedit.ChanIndex==0;
        g.eventedit.ChanIndex=1;
    end
    if g.eventedit.ChanIndex>size(uda,1);
        g.eventedit.ChanIndex=size(uda,1);
    end
end
clear tmpChanIndex

% Check for event selection.
%if ~isempty(EEG.event);
    pntdist=ceil((udf.winlength*udf.srate)*0.002);
    % Check for event selection.
    if isfield(g.eventedit, 'SelEventStruct');
        g=rmfield(g.eventedit,'SelEventStruct');
    end
    j=0;
    for i=1:length(udf.events);
        if abs(udf.events(i).latency-g.eventedit.PosLat)<pntdist;
            j=j+1;
            g.eventedit.SelEventStruct(j).index=i;
            g.eventedit.SelEventStruct(j).dist=abs(udf.events(i).latency-round(g.tmppos(1,1)+g.eventedit.WinStartPnt));
            g.eventedit.SelEventStruct(j).type=udf.events(i).type;
            g.eventedit.SelEventStruct(j).latency=udf.events(i).latency;
        end
    end
%end


if strcmp(g.select_mark,'on');
    ylims=get(gca,'YLim');
    cxpnt=g.eventedit.WinStartPnt+round(g.tmppos(1,1));
    
    inter_time_mark_offset=diff(ylims)*udf.inter_mark_int;
    time_marks_offset=diff(ylims)*udf.marks_y_loc;
    for tmi=1:length(udf.time_marks_struct);
        for i=1:length(time_marks_offset)
            l=ylims(1)+inter_time_mark_offset*tmi+(time_marks_offset(i))-(inter_time_mark_offset*length(udf.time_marks_struct));
            h=ylims(1)+inter_time_mark_offset*tmi+(time_marks_offset(i))+inter_time_mark_offset-(inter_time_mark_offset*length(udf.time_marks_struct));
            if g.tmppos(1,2)>l&&g.tmppos(1,2)<h;
                disp(['hit mark Y ',num2str(tmi)]);
                if udf.time_marks_struct(tmi).flags(cxpnt);
                    disp(['hit mark X ' num2str(cxpnt)]);
                    for pi=1:cxpnt-1;
                        if udf.time_marks_struct(tmi).flags(cxpnt-pi)==0||cxpnt-pi==0;
                            bnd(1)=cxpnt-(pi-1);
                            break
                        end
                    end
                    for pi=1:size(uda,2)-cxpnt;
                        if udf.time_marks_struct(tmi).flags(cxpnt+pi)==0||cxpnt+pi==size(uda,2);
                            bnd(2)=cxpnt+pi;
                            break
                        end
                    end
                    if size(udf.winrej,2)==2;
                        udf.winrej(size(udf.winrej,1)+1,:)=bnd;
                    else
                        udf.winrej(size(udf.winrej,1)+1,1:2)=bnd;
                        udf.winrej(size(udf.winrej,1)+1,3:5)=udf.wincolor;
                        udf.winrej(size(udf.winrej,1)+1,6:size(udf.winrej,2))=zeros(1,size(udf.winrej,2)-5);                        
                    end
                    set(gcf,'userdata',udf);
                    ve_eegplot('drawp',0);
                end
            end
        end
    end
    return
end

if ~isempty(g.add_winrej_mark)||~isempty(g.rm_winrej_mark)
    cxpnt=g.eventedit.WinStartPnt+round(g.tmppos(1,1));
        
    for wi=1:size(udf.winrej,1)
        if cxpnt>udf.winrej(wi,1)&&cxpnt<udf.winrej(wi,2)
            disp(['hit winrej X ' num2str(cxpnt)]);
            %find mark index
            if ~isempty(g.add_winrej_mark)
                if strcmp(g.add_winrej_mark,'pop_select')
                    label_index=pop_chansel({udf.time_marks_struct.label});
                else
                    label_index=find(strcmp(g.add_winrej_mark,{udf.time_marks_struct.label}));
                end
                if isempty(label_index);
                    tmp_marks_struct.time_info=udf.time_marks_struct;
                    %tmp_marks_struct.chan_info=udf.chan_marks_struct;
                    tmp_marks_struct=pop_marks_add_label(tmp_marks_struct,'info_type','time_info', ...
                                            'label',g.add_winrej_mark, ...
                                            'action','add', ...
                        'message','Fill in the missing information for the mark that you are adding.');
                    udf.time_marks_struct=tmp_marks_struct.time_info;
                    if strcmp(g.add_winrej_mark,'pop_select')
                        label_index=pop_chansel({udf.time_marks_struct.label});
                    else
                        label_index=find(strcmp(g.add_winrej_mark,{udf.time_marks_struct.label}));
                    end
                    
                end
                udf.time_marks_struct(label_index).flags(round(udf.winrej(wi,1)):round(udf.winrej(wi,2)))=1;
                if strcmp(g.data_move,'on');
                    if ~isfield(udf,'urdata');udf.urdata=uda;end
                    if isfield(udf,'data2');
                        uda(:,(round(udf.winrej(wi,1)):round(udf.winrej(wi,2))))=udf.data2(:,(round(udf.winrej(wi,1)):round(udf.winrej(wi,2))));
                        set(gca,'userdata',uda);
                    end
                end
            end
            if ~isempty(g.rm_winrej_mark)
                if strcmp(g.rm_winrej_mark,'pop_select')
                    label_index=pop_chansel({udf.time_marks_struct.label});
                else
                    label_index=find(strcmp(g.rm_winrej_mark,{udf.time_marks_struct.label}));
                end
                udf.time_marks_struct(label_index).flags(round(udf.winrej(wi,1)):round(udf.winrej(wi,2)))=0;
                if strcmp(g.data_move,'on');
                    if isfield(udf,'urdata');
                        uda(:,(round(udf.winrej(wi,1)):round(udf.winrej(wi,2))))=udf.urdata(:,(round(udf.winrej(wi,1)):round(udf.winrej(wi,2))));
                        set(gca,'userdata',uda);
                    end
                end
            end
            set(gcf,'userdata',udf);
            ve_eegplot('drawp',0)
        end
    end
    return
end

%if ~isempty(g.rm_winrej_mark)
%    cxpnt=g.eventedit.WinStartPnt+round(g.tmppos(1,1));
%        
%    for wi=1:size(udf.winrej,1)
%        if cxpnt>udf.winrej(wi,1)&&cxpnt<udf.winrej(wi,2)
%            disp(['hit winrej X ' num2str(cxpnt)]);
%            %find mark index
%            if strcmp(g.rm_winrej_mark,'pop_select')
%                label_index=pop_chansel({udf.time_marks_struct.label});
%            else
%                label_index=find(strcmp(g.add_winrej_mark,{udf.time_marks_struct.label}));
%            end
%            udf.time_marks_struct(label_index).flags(round(udf.winrej(wi,1)):round(udf.winrej(wi,2)))=0;
%            set(gcf,'userdata',udf);
%            ve_eegplot('drawp',0)
%        end
%    end
%    return
%end


% Call event edit UI.

pop_ve_edit(g);
