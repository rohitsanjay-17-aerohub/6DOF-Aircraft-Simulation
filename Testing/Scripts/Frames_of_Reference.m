%Frames of Reference for Flight Mechanics
%Euler Angles are given by psi, theta and phi to match the earth axis to
%the body axis

syms psi theta phi;
Lpsi = [cos(psi) sin(psi) 0;-sin(psi) cos(psi) 0;0 0 1];
Ltheta = [cos(theta) 0 -sin(theta);0 1 0;sin(theta) 0 cos(theta)];
Lphi = [1 0 0;0 cos(phi) sin(phi);0 -sin(phi) cos(phi)];
LEB = Lphi*Ltheta*Lpsi;

%Velocity in Earth frame of Reference is given by taking derivative of the
%position vector which is nothing but LBE times Vb.

LBE = inv(LEB);
syms u v w ib jb kb;
VE = LBE*[u;v;w]

%Angular Velocity 
Frame_1 = (Ltheta^-1)*(Lphi^-1)*[ib;jb;kb];
Frame_1 = simplify(Frame_1)
Frame_2 = (Lphi^-1)*[ib;jb;kb];
Frame_2 = simplify(Frame_2)

k1 = Frame_1(3,:)
j2 = Frame_2(2,:)

%Translational Motion in the body frame
syms u_dot v_dot w_dot p q r m;
FB = m*([u_dot;v_dot;w_dot]+cross([p;q;r],[u;v;w]))


%Rotational Motion
syms p_dot q_dot r_dot Ixx Iyy Izz Ixz  
Mext = [Ixx 0 -Ixz;0 Iyy 0;-Ixz 0 Izz]*[p_dot;q_dot;r_dot]+cross([p;q;r],[Ixx 0 -Ixz;0 Iyy 0;-Ixz 0 Izz]*[p;q;r])