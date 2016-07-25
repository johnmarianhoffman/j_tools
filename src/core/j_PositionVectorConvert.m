function out_pos=j_PositionVectorConvert(pos,conv)

switch conv
  case 'm->c'
    out_pos(1)=pos(1)+pos(3)/2;
    out_pos(2)=pos(2)+pos(4)/2;
    out_pos(3)=pos(3);
    out_pos(4)=pos(4);
  case 'c->m'
    out_pos(1)=pos(1)-pos(3)/2;
    out_pos(2)=pos(2)-pos(4)/2;
    out_pos(3)=pos(3);
    out_pos(4)=pos(4);
end

end