
glovesneeded.

+!tellAboutObjects <-
	.findall(F, friend(F), Friends);
	for (wood(X, Y)[source(percept)]) {
		+wood(X, Y);
		.send(Friends, tell, wood(X, Y));
	};
	for (gold(X, Y)[source(percept)]) {
		+gold(X, Y);
		.send(Friends, tell, gold(X, Y));
	};
	for (spectacles(X, Y)[source(percept)]) {
		+spectacles(X, Y);
		.send(Friends, tell, spectacles(X, Y));
	};
	for (gloves(X, Y)[source(percept)]) {
		+gloves(X, Y);
		.send(Friends, tell, gloves(X, Y));
	};
	if (shoes(X, Y)[source(percept)]) {
		+shoes(X, Y);
		.send(Friends, tell, shoes(X, Y));
	}.

+step(0) <- 
	!tellAboutObjects;
	.println("START");?grid_size(A,B);+right(A);+down(B);+right;do(skip);do(skip).


+step(X): gloves(A,B) & pos(A,B) & glovesneeded <-
	!tellAboutObjects;
	//-glovesneeded;
	do(pick).
	
+step(X): gloves(A,B) & glovesneeded <- 
	!goTo(A,B).
	
+!goTo(X,Y) : pos(X,Y).
+!goTo(X,Y) : moves_left(Z) & (Z > 0) <-
	?pos(A,B);
	if ((X - A) \== 0) {
		!goVerticaly(Y);
		!goTo(X,Y);
	} else {
		if ((Y - B) \== 0) {
			!goHorizontaly(X);
			!goTo(X,Y);
		};
	}.
	
+!goVerticaly(Y) <-
	?pos(A,B);
	if (Y > B) {
		!go(up);
	} else {
		!go(down);
	}.
	
+!goHorizontaly(X) <-
	?pos(A,B);
	if (X > A) {
		!go(right);
	} else {
		!go(left);
	}.
	
+!go(X) <-
	do(X);
	!tellAboutObjects.
	


	
 
+step(X):carrying_capacity(Y)&carrying_wood(Z)<-!tellAboutObjects;.println("Unesu ",Y,", nesu ",Z);!go.

 +!go:pos(A,B)&wood(A,B)<-do(pick).

 +!go: right & pos(A,B) & right(C)&A<C-1<- do(right);do(skip).
 +!go: right <- -right;+left;do(down);do(skip).	
 +!go: left & pos(A,B) & A>0 <- do(left);do(skip).	
 +!go: left<-  -left;+right;do(down);do(skip).



