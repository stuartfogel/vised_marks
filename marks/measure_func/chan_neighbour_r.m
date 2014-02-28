function [EEG,m_neigbr_r,chandist,y,chan_win_sd]=chan_neighbour_r(EEG,nneigbr,method,varargin)

g=struct(varargin{:});

try g.chinds;    catch, g.chinds=1:EEG.nbchan; end;
try g.latinds;   catch, g.latinds=1:EEG.pnts; end;
try g.plotfigs;  catch, g.plotfigs='off'; end;

tmp.chanlocs = EEG.chanlocs(g.chinds);
tmp.data     = EEG.data(g.chinds,:,g.latinds);

nchan=size(tmp.data,1);
ntrial=size(tmp.data,3);

chandist=zeros(nchan,nchan,3);
for chani=1:nchan;
    for chanii=1:nchan;
        if ~isempty(tmp.chanlocs(chanii).X)
            chandist(chani,chanii,1)=tmp.chanlocs(chanii).X-tmp.chanlocs(chani).X;
            chandist(chani,chanii,2)=tmp.chanlocs(chanii).Y-tmp.chanlocs(chani).Y;
            chandist(chani,chanii,3)=tmp.chanlocs(chanii).Z-tmp.chanlocs(chani).Z;
        else
            disp('At least one of the selected channels is missing coordinate infomation... quitting.');
            return            
        end
    end
end

chandist=sum(abs(chandist),3);

[~,y]=sort(chandist,2,'ascend');

c_neigbr_r=zeros(nchan,ntrial,nneigbr);

if strcmp(g.plotfigs,'on')
    hchanr = waitbar(0,['Calculating nearest reighbour r for channel 0 of ', num2str(nchan), '...']);
end
for i=1:nchan;
    if strcmp(g.plotfigs,'on')
        waitbar(i/EEG.nbchan,hchanr, ...
            ['Calculating nearest reighbour r for channel ' num2str(i), ' of ', num2str(nchan), '...'])
    end
    for ii=1:ntrial;
        %tic
        for iii=1:nneigbr;
            tmp_neigbr_r=corrcoef(squeeze(tmp.data(i,:,ii)),squeeze(tmp.data(y(i,iii+1),:,ii)));
            if max(size(tmp_neigbr_r))==1;%Octave returns singlton...
                c_neigbr_r(i,ii,iii)=tmp_neigbr_r;
            else % Matlab returns 2 x2 array...
                c_neigbr_r(i,ii,iii)=tmp_neigbr_r(1,2);
            end
        end
        %toc
    end
end

if strcmp(g.plotfigs,'on')
    close(hchanr);
end
switch(method);
    case 'max'
        m_neigbr_r=max(abs(c_neigbr_r),[],3);

    case 'mean'
        m_neigbr_r=mean(abs(c_neigbr_r),3);
    
    case 'trimmean'
        m_neigbr_r=trimmean(abs(c_neigbr_r),20,3);
end

chan_win_sd=squeeze(std(EEG.data,[],2));