function S = b_spline(P,k,Dt,open)

% P = Input path, size = n x 3
% k = Order
% open==1: open spline path, open==0: closed spline path

if open==0 % closed path
    for i=1:k+1
        P=[P;P(i,:)];
    end
end

n = length(P); %number of control points
m = n+k; %number of knots
dt = 1;

%knot vector
T = zeros(m,1);
for ti=1:k
    T(ti) = 0;
end
for ti=k+1:m-k
    T(ti) = T(ti-1)+dt;
end
for ti=m-k+1:m
    if ti==m-k+1
        T(ti) = T(ti-1)+dt;
    else
        T(ti) = T(ti-1);
    end
end



%B-spline curve fitting
S = [];
ti=1;
B = zeros(length(T),n,k);

start_idx = 1;
finish_idx = m;

%start_idx = k+1;
%finish_idx = m-k;

if open==0 % closed path
    start_idx = k+1;
    finish_idx = m-k;
end

for t = T(start_idx):Dt:T(finish_idx)
    
    % De boor's recursion
    for j=1:k
        for i=1:n+k-1
            if j==1
                if t>=T(i) && t<T(i+1)
                    B(ti,i,j) = 1;
                else
                    B(ti,i,j) = 0;
                end
            else
                if T(i+j-1) == T(i)
                    r1 = 0;
                else
                    r1 = (t-T(i))/(T(i+j-1)-T(i));
                end                
                if T(i+j) == T(i+1)
                    r2 = 0;
                else
                    r2 = (T(i+j)-t)/(T(i+j)-T(i+1));
                end
                B(ti,i,j) = r1*B(ti,i,j-1) + r2*B(ti,i+1,j-1);
            end
        end
        n=n-1;
    end
    n = length(P);
  
    if t==T(1)
        B(ti,1,k) = 1;
    end
    if t==T(m)
        B(ti,n,k) = 1;
    end
    
    s = zeros(1,size(P,2));
    for si=1:m-k
        s = s + P(si,:)*B(ti,si,k);
    end
    S = [S;s];
    ti=ti+1;
end
% 
% figure(1)
% plot(B(:,1,k),'r');
% hold on
% plot(B(:,2,k),'g');
% plot(B(:,3,k));
% plot(B(:,4,k));
% plot(B(:,5,k));
% plot(B(:,6,k));
% plot(B(:,7,k));
% plot(B(:,8,k));
% plot(B(:,9,k),'c');
% plot(B(:,10,k),'m');
% title('Basis Functions');

end