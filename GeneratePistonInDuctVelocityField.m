% Copyright (c) 2019, Fernando Zigunov
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
%
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
%
% * Neither the name of  nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


function [Vfield_Snapshots,xdata,ydata, t] = GeneratePistonInDuctVelocityField()
%This example defines the mathematical solution to the piston in an infinite duct problem:
%        ---------=========------------

%<<-inf                                   inf>>

%        ------------------------------

%Walls -> ---------
%Piston -> =========
%Considering a 2D domain subject to the wave equation:
%d2v(x,y,t)/dx2 + d2v(x,y,t)/dy2 = d2v(x,y,t)/dt2
%under B.C.s
%v(y=0)=0;
%v(y=H)=0, if |x|<L; and epsilon*sin(omega*t) if |x|<L

%This computes the Fourier modes of the solution for a specific case:
H=10;
omega=1;
L=3;
t=linspace(0,10*pi,100);
SNR=0.5; %Signal-to-noise-ratio for adding noise to the solution (greater values mean better signal quality)

x=linspace(-10*L,10*L,1000);
y=linspace(0,H,200);

[X,Y]=meshgrid(x,y);

%%
V=zeros(size(X));
for n=1:10
    k0=sqrt(omega.^2-(n*pi/H).^2);

    An=(2*1i*pi^2/(H^2))*(n*((-1)^n))*sin(n*pi*Y/H)/(k0^2);

    %Combined Solution
    Iout=sign(X).*An.*2.*1i.*exp(1i*abs(X)*k0).*sin(k0.*L);
    Iout(abs(X)<L)=0;

    Iin=2*1i*An.*exp(1i*L*k0).*sin(k0.*X);
    Iin(abs(X)>L)=0;

    V=V+Iout+Iin;
end

%Now puts this solution inside a 3D matrix for POD computation.
%Here we'll also add speckle noise to make it more interesting.

Vfield_Snapshots=zeros(length(t),size(V,1),size(V,2));
for i=1:length(t)
    Noise=rand(size(V))>0.7; %Speckle noise
    Vfield_Snapshots(i,:,:)=imag(exp(-1i*omega*t(i))*V) + Noise*max(imag(V(:)))/SNR;
end

xdata = x/L;
ydata = y/H;
end