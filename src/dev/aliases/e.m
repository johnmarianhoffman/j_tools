function e

s=input('Really exit? [Y],N','s');

if isempty(s)
    s='Y';
end

switch upper(s)
    case 'Y'
        exit
    case 'YES'
        exit
    otherwise
        return;
end

