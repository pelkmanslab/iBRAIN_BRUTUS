% Parsing String data
function Parse_String_iBrain(Edge_threshold,Edge_type)

if Edge_threshold==0
    Edge_threshold=1;
end
genes=6979;

load(npc('X:\Data\Users\Pauli\String_apriori_precalc\Meta_Data.mat'))
load(npc('X:\Data\Code\STRING8\DG_to_STRING_mapping\cell_DG_to_STRING80.mat'))
load(npc('X:\Data\Code\STRING8\STRING8.2\091019_String82_files.mat'),'matPROTEIN_IDS')
load(npc('X:\Data\Code\STRING8\STRING8.2\091019_String82_partial_scores.mat'))

%Edge_type=[3 4 5]; % Different String edge types: 'neighborhood'    'fusion'    'cooccurence'    'coexpression'    'experimental'    'database' 'textmining'    'combined_score'
%Edge_threshold=[10 10 700]; % Threshold value for the edges


% for Edge_threshold=[1,10:10:1000]
%     clear Connections ConnectionsTriang
%
%     for Edge_type=1:8
disp([cellAllScoreHeader{Edge_type},': ',num2str(Edge_threshold)]);

% Getting the StringID's for DG genes
String_geneID=cell2mat(cellDG_to_STRING80(:,2));
String_stringID=cell2mat(cellDG_to_STRING80(:,4));

for gene=1:genes
    DG_stringID(gene)=String_stringID(String_geneID==MetaData.GeneIDs(gene));
end

edge_indices=find(matAllScores(:,Edge_type)>Edge_threshold);

PPI=matPROTEIN_IDS(edge_indices,:);
PPI=PPI(ismember(PPI(:,1),DG_stringID)&ismember(PPI(:,2),DG_stringID),:); % Leaving only edges between DG nodes

% Precalculating the connections of each DG node
for gene=1:genes
    gene_StringID=DG_stringID(gene);
    nodeIDs=[PPI(PPI(:,1)==gene_StringID,2);PPI(PPI(:,2)==gene_StringID,1)]; %finding to which nodes the gene is connected to
    nodeIDs(nodeIDs==gene_StringID)=[]; %removing loops

    Connections.(cellAllScoreHeader{Edge_type}).(['T',num2str(Edge_threshold)]){gene}=unique(nodeIDs);

    between_connections=...
        ismember(PPI(:,1),Connections.(cellAllScoreHeader{Edge_type}).(['T',num2str(Edge_threshold)]){gene})...
        &ismember(PPI(:,2),Connections.(cellAllScoreHeader{Edge_type}).(['T',num2str(Edge_threshold)]){gene});
    ConnectionsTriang.(cellAllScoreHeader{Edge_type}).(['T',num2str(Edge_threshold)]){gene}...
        =unique([PPI(between_connections,1);PPI(between_connections,2)]);  % here taking connections only to other nodes that form triangles
end
%end
save(npc(['X:\Data\Users\Pauli\String_apriori_precalc\Connections_',num2str(Edge_threshold),'_',num2str(Edge_type)]),'Connections')
save(npc(['X:\Data\Users\Pauli\String_apriori_precalc\ConnectionsTriang_',num2str(Edge_threshold),'_',num2str(Edge_type)]),'ConnectionsTriang')

%end

%MetaData.DG_stringID=DG_stringID;
%MetaData.String_geneID=String_geneID;
%MetaData.String_stringID=String_stringID;  