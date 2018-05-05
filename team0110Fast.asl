shoesNeeded.


!start.
+!start <- +right.


+step(_) <- while (moves_left(N) & N > 0) { !go; }.

+carrying_wood(0) <- -goToDepot.
+carrying_wood(N): carrying_capacity(N) <- +goToDepot.

+wood(X, Y) <- +goTo(X, Y).
+shoes(X, Y) <- +goTo(X, Y).

-wood(X, Y) <- -goTo(X, Y).
-shoes(X, Y) <- -goTo(X, Y).



+!go: moves_left(0).

@drop[atomic] +!go: pos(A, B) & depot(A, B) & goToDepot <-
	if (moves_left(N) & moves_per_round(M) & N == M) {
		do(drop); -goToDepot;
	} else {
		while (moves_left(N) & N > 0) { do(skip); }
	}.

+!go: goToDepot & depot(A, B) <- !goTo(A, B).

@pickShoes[atomic] +!go: pos(A, B) & shoesNeeded & shoes(A, B)[source(percept)] <-
	if (moves_left(N) & moves_per_round(M) & N == M) {
		do(pick); -shoesNeeded;
	} else { 
		while (moves_left(N) & N > 0) { do(skip); }
	};
	.findall(F, friend(F), Friends);
	.send(Friends, untell, shoes(X, Y)).
	
@pickWood[atomic] +!go: pos(A, B) & wood(A, B)[source(percept)] <-
	if (moves_left(N) & moves_per_round(M) & N == M) {
		do(pick);
	} else {
		while (moves_left(N) & N > 0) { do(skip); }
	};
	.findall(F, friend(F), Friends);
	.send(Friends, untell, wood(X, Y)).
	
+!go: pos(A, B) & goTo(A, B) <- -goTo(A, B).
+!go: pos(A, B) & goTo(X, Y) <- !goTo(X, Y).

+!go: right & pos(A, B) & grid_size(X, Y) & A < Y-1 <- !go(right).
+!go: right & pos(A, B) <- -right; +left; !go(up); !go(up); !go(up).

+!go: left & pos(A, B) & A >= 1 <- !go(left).
+!go: left & pos(A, B) <- -left; +right; !go(up); !go(up); !go(up).

+!go: moves_left(N) & N > 0 <- !go(skip).



@go[atomic] +!go(X) <- if (moves_left(N) & N > 0) { do(X); !explore; }.


+!goTo(X, Y): pos(A, B) <-
	if ((X - A) \== 0) {
		if (X > A) { !go(right); } else { !go(left); }
	} else {
		if ((Y - B) \== 0) {
			if (Y > B) { !go(down); } else { !go(up); }
		};
	}.


 
+!explore: pos(X, Y) <-
	+explore(X, Y);
	+explore(X, Y - 1);
	+explore(X, Y + 1);
	+explore(X - 1, Y);
	+explore(X + 1, Y);
	+explore(X - 1, Y - 1);
	+explore(X - 1, Y + 1);
	+explore(X + 1, Y - 1);
	+explore(X + 1, Y + 1);
	.

+explore(X, Y) <-
	.findall(F, friend(F), Friends);
	
	if (depot(X, Y)[source(percept)]) { .send(Friends, tell, depot(X, Y)); }

	if (obstacle(X, Y)[source(percept)]) { .send(Friends, tell, obstacle(X, Y)); }
	
	if (gold(X, Y)[source(percept)]) { .send(Friends, tell, gold(X, Y)); }
	if (not gold(X, Y)[source(percept)]) { .send(Friends, untell, gold(X, Y)); }
	
	if (wood(X, Y)[source(percept)]) { .send(Friends, tell, wood(X, Y)); }
	if (not gold(X, Y)[source(percept)]) { .send(Friends, untell, wood(X, Y)); }
	
	if (spectacles(X, Y)[source(percept)]) { .send(Friends, tell, spectacles(X, Y)); }
	if (not spectacles(X, Y)[source(percept)]) { .send(Friends, untell, spectacles(X, Y)); }
	
	if (gloves(X, Y)[source(percept)]) { .send(Friends, tell, gloves(X, Y)); }
	if (not gloves(X, Y)[source(percept)]) { .send(Friends, untell, gloves(X, Y)); }
	
	if (shoes(X, B)[source(percept)]) { .send(Friends, tell, shoes(X, Y)); }
	if (not shoes(X, B)[source(percept)]) { .send(Friends, untell, shoes(X, Y)); }
	
	-explore(X, Y).
