# RandFracGen-Matlab

 Generates randomly distributed oriented fractures


**INPUT**

 Mx    (Integer) : X size of final domain 

 My    (Integer) : Y size of final domain

 theta (Radian)  : Angle of rotation +ve values only

 N     (Integer) : Size of unrotated Domain. Controls orthogonal spacing between fractures

 tun   (Integer) : Size of fracture, 2 for small fractures, 9 for large fractures. Controls spacing between fracture tips

 plot  (0 or 1)  : Visualization, 1 for plotting, 0 for no plots (plotting increase computation time)


**ESSENTIAL STEPS**

 Generates random fractures in the domain of the size NxN

 Rotates the domain and fractures by theta

 Selects the rotated fractures

 Removes fractures of size 0 and size 1

 Rescales the problem to Mx by My size


**OUTPUT**

 LocationR     : Fracture location matrix with the syntax [X_Beg Y_Beg X_End Y_End Fractre_Number]

 Dom           : Class object containing fracture class and elements in each fracture. 


**CALLING EXAMPLE**

 For

 N=500

 Mx=My=5

 theta=pi/12 radians  or 15 degrees counterclockwise

 tun = 5 (medium sized fractures, no bias)

 plot= 1 show plots

>[locationR, Dom]=RandFracGen(500,5,5,pi/12,5,0);


*Result*
>locationR

    [
    4.85914722539209	0.000221163463716518	4.87095373938303	0.00338470935301598	1
    4.87095373938303	0.00338470935301598	4.88276025337397	0.00654825524231509	1
    4.88276025337397	0.00654825524231509	4.89456676736491	0.00971180113161420	1
    4.89456676736491	0.00971180113161420	4.90637328135585	0.0128753470209133	1
    4.90637328135585	0.0128753470209133	4.91817979534679	0.0160388929102128	1
    4.77017453567691	0.00168937022050279	4.78198104966785	0.00485291610980208	2
    4.78198104966785	0.00485291610980208	4.79378756365879	0.00801646199910119	2
    ...
    ]

>Dom

    RandGenDomain with properties:
      loc: []
      locR: [28571×4 double]
      Fn: [28571×1 double]
      Frac: [7164×1 RandGenFracture]
      Nf: 7164

>Dom.Frac(1)

    RandGenFracture with properties:
      Ne: 5
      Fn: 1
      loc: [26×4 double]
      locR: [5×4 double]

![Alt text](/images/RandFracU.jpg?raw=true "Selection Box")
![Alt text](/images/RandFracR.jpg?raw=true "Output rotated fractures")

    
