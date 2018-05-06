shoesNeeded.


!start.
+!start <- !randomizeGoTo.


+step(_) <- while (moves_left(N) & N > 0) { !tryFindGoal; !go; }.

+carrying_wood(0) <- -goToDepot.
+carrying_wood(N): carrying_capacity(N) <- +goToDepot.

+carrying_gold(N): N > 0 <- +goToDepot.

+wood(X, Y) <-
	!isGoalAvailable(wood, X, Y, R);
	if (R) { +goal(wood, X, Y); }
	else { -goal(wood, X, Y); }.
+shoes(X, Y) <- +goal(shoes, X, Y).

+helpNeeded(X, Y) <-
	if (carrying_wood(N) & N > 0) { +goToDepot; }
	+goal(help, X, Y); +goTo(X, Y).
-helpNeeded(X, Y) <-
	-goal(help, X, Y); -goTo(X, Y).

-wood(X, Y) <- -goal(wood, X, Y).
-shoes(X, Y) <- -goal(shoes, X, Y).

+goTo(X,Y) <- .print("+goTo(", X, ",", Y, ")").


+!tryFindGoal: goal(_, _, _).
+!tryFindGoal: wood(A, B) <- +goal(wood, A, B).
+!tryFindGoal: shoesNeeded & shoes(A, B) <- +goal(shoes, A, B).
+!tryFindGoal: carrying_wood(N) & N > 1 <- +goToDepot.
+!tryFindGoal.


+!isGoalAvailable(A,X,Y, Result) <-
	.findall(F, friend(F), Friends);
	.nth(0, Friends, Slow);
	.send(Slow, askOne, goal(A,X,Y), GoalSlow);
	.nth(1, Friends, Fast);
	.send(Fast, askOne, goal(A,X,Y), GoalFast);
	if ((GoalSlow == goal(A,X,Y)[source(Slow)]) | 
		(GoalFast == goal(A,X,Y)[source(Fast)])){
		.term2string(Result, "false");
	} else {
		.term2string(Result, "true");
	}.



+!go: moves_left(0).

+!go: pos(A, B) & goal(_, A, B) <- -goal(_, A, B).
+!go: pos(A, B) & goTo(A, B) <- -goTo(A, B); !randomizeGoTo.

@drop[atomic] +!go: pos(A, B) & depot(A, B) & goToDepot <-
	if (moves_left(N) & moves_per_round(M) & N == M) {
		do(drop); -goToDepot;
	} else {
		while (moves_left(N) & N > 0) { do(skip); }
	}.

+!go: goToDepot & depot(A, B) <- !goTo(A, B).

@help[atomic] +!go: pos(A, B) & helpNeeded(A, B) & gold(A, B)[source(percept)] <-
	while (moves_left(N) & N > 0) { do(skip); }.

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
	
+!go: pos(A, B) & goal(_, X, Y) <- !goTo(X, Y).

+!go: pos(A, B) & goTo(X, Y) <- !goTo(X, Y).

+!go: moves_left(N) & N > 0 <- !randomizeGoTo. // !go(skip).



+!go(up): goObstacle(up) <- !go(right).
+!go(down): goObstacle(down) <- !go(left).
+!go(left): goObstacle(left) <- !go(up).
+!go(right): goObstacle(right) <- !go(down).

+!checkObstacles: pos(X, Y) <-
	if (obstacle(X, Y - 1)) { +goObstacle(up); }
	else { -goObstacle(up) };
	if (obstacle(X, Y + 1)) { +goObstacle(down); }
	else { -goObstacle(down) };
	if (obstacle(X - 1, Y)) { +goObstacle(left); }
	else { -goObstacle(left) };
	if (obstacle(X + 1, Y)) { +goObstacle(right); }
	else { -goObstacle(right) }.

@go[atomic] +!go(X) <-
	!checkObstacles;
	if (not goObstacle(X) & moves_left(N) & N > 0) { do(X); !explore; }.


+!goTo(X, Y): pos(A, B) <-
	if (math.floor(math.random(2)) == 0) {
		if ((X - A) \== 0) {
			if (X > A) { !go(right); } else { !go(left); }
		} else {
			if ((Y - B) \== 0) {
				if (Y > B) { !go(down); } else { !go(up); }
			}
		}
	} else {
		if ((Y - B) \== 0) {
				if (Y > B) { !go(down); } else { !go(up); }
		} else {
			if ((X - A) \== 0) {
				if (X > A) { !go(right); } else { !go(left); }
			}
		}
	}.

	
/* GoTo random edge */
+!randomizeGoTo <- !randomizeGoTo(math.floor(math.random(4))).
+!randomizeGoTo(0) <- ?grid_size(X, Y); +goTo(0, math.floor(math.random(Y))).
+!randomizeGoTo(1) <- ?grid_size(X, Y); +goTo(X - 1, math.floor(math.random(Y))).
+!randomizeGoTo(2) <- ?grid_size(X, Y); +goTo(math.floor(math.random(X)), 0).
+!randomizeGoTo(3) <- ?grid_size(X, Y); +goTo(math.floor(math.random(X)), Y - 1).
	

 
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
