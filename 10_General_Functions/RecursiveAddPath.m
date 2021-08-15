function [] = RecursiveAddPath( root )
%Hinzufügen aller Unterordner als Matlap path

addpath(root)
files = dir(root);
dirFlags = [files.isdir] & ~strcmp({files.name},'.') & ~strcmp({files.name},'..');
subFolders = files(dirFlags);
if ~isempty(subFolders)
    for k = 1 : length(subFolders)
        if subFolders(k).name(1) ~= '@'
            RecursiveAddPath([root, filesep, subFolders(k).name])
        end
    end

end

